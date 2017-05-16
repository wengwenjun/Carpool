//
//  ChatViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/4/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()
@property(nonatomic,strong) FIRDatabaseReference *ref;
@property (nonatomic, strong) NSMutableArray * messages;
@property (nonatomic) JSQMessagesBubbleImage * outgoingBubbleImageView;
@property(nonatomic) JSQMessagesBubbleImage *incomingBubbleImageView;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.senderId = [[FIRAuth auth] currentUser].uid;
    self.messages  = [[NSMutableArray alloc] init];
    FIRUser *currentUser = [[FIRAuth auth]currentUser];
    self.senderId = currentUser.uid;
    self.senderDisplayName = self.senderName;
    self.outgoingBubbleImageView = [self outgoingMessagesBubbleImage];
    self.incomingBubbleImageView = [self incomingMessagesBubbleImage];
    // Do any additional setup after loading the view.
}
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"%@",self.messages[indexPath.item]);
    return self.messages[indexPath.item];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    //NSLog(@"%ld",[self.messages count]);
    return [self.messages count];
}

-(void) listOfMessage :(id) senderid displayName:(NSString *)displayname withText:(NSString *)text{
    JSQMessage *message = [JSQMessage messageWithSenderId:senderid displayName:displayname text:text];
    [self.messages addObject:message];
    //NSLog(@"%@",self.messages);
}

- (JSQMessagesBubbleImage *)outgoingMessagesBubbleImage
{
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessagesBubbleImage *out=  [factory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    return out;
}

- (JSQMessagesBubbleImage *)incomingMessagesBubbleImage
{
    JSQMessagesBubbleImageFactory *factory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    JSQMessagesBubbleImage *in = [factory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    return in;
}

- (JSQMessagesBubbleImage *)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage*  message = [self.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString: self.senderId])  {
        return self.outgoingBubbleImageView;
    } else {
        return self.incomingBubbleImageView;
    }}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"senderId"] = self.senderId;
    dict[@"senderName"] = self.senderDisplayName;
    dict[@"receiveId"] = self.receiveId;
    dict[@"receivedName"] = self.receiveName;
    dict[@"text"] = text;
    [[[self.ref child:@"messages"]childByAutoId]updateChildValues:dict];
    [self finishSendingMessage];
}
-(void) loadAllMessages {
    FIRDatabaseQuery *allMessages = [[self.ref child:@"messages"]queryLimitedToLast:25];
    [allMessages observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot){
        NSMutableDictionary *dict = snapshot.value;
        NSString *senderid =  dict[@"senderId"];
        NSString *senderName = dict[@"senderName"];
        NSString *text = dict[@"text"];
        NSError *error;
        if(([self.receiveId isEqualToString:dict[@"receiveId"]] && [self.senderId isEqualToString: dict[@"senderId"]])||([self.receiveId isEqualToString:dict[@"senderId"]] && [self.senderId isEqualToString: dict[@"receiveId"]])){
            [self listOfMessage:senderid displayName:senderName withText:text];
        }else{
            NSLog(@"%@",error.localizedDescription);        }
        [self finishReceivingMessage];
    }];
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    [self loadAllMessages];
    // animates the receiving of a new message on the view
    //finishReceivingMessage();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
