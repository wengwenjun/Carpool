//
//  FriendListViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/7/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "FriendListViewController.h"
#import "FriendListTableViewCell.h"
#import "ChatViewController.h"
@import Firebase;

@interface FriendListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) NSString *currentUserID;
@property (nonatomic) NSMutableArray * friendArray;
@property (nonatomic) NSMutableArray *friendNameArray;
@property (nonatomic) NSString *currentUserName;
@property (nonatomic) NSString *receiveID;
@property (nonatomic) NSString *receiveName;

@end

@implementation FriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database]reference];
    self.currentUserID = [[FIRAuth auth]currentUser].uid;
    FIRDatabaseQuery *currentUser = [[self.ref child:@"publicUsers"]child:self.currentUserID];
    [currentUser observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    self.currentUserName = snapshot.value[@"name"];
    }];
    self.friendNameArray = [[NSMutableArray alloc]init];
    [self findAllFriends];
    // Do any additional setup after loading the view.
}

-(void) findAllFriends{
    self.friendArray = [[NSMutableArray alloc] init];
    FIRUser * currentUser = [[FIRAuth auth] currentUser];
    FIRDatabaseQuery *allFriends = [[[[self.ref child:@"publicUsers"]child:self.currentUserID]child:@"friendList"]queryLimitedToFirst:10];
    //NSLog(@"%@", allFriends);
    [allFriends observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(NSDictionary *item in snapshot.value){
           // NSLog(@"%@",snapshot.value);
            //NSLog(@"%@",item);
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            dict[@"friendId"] = item;
            [self.friendArray addObject:dict];
            NSLog(@"friend array %@", self.friendArray);
            [self.tblView reloadData];
        }
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.friendArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendListTableViewCell" forIndexPath:indexPath];
    NSString* friendID = [[self.friendArray objectAtIndex:indexPath.row]valueForKey:@"friendId"];
    FIRDatabaseQuery *findFriend = [[self.ref child:@"publicUsers"]child:friendID];
    [findFriend observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        cell.friendName.text = snapshot.value[@"name"];
        [self.friendNameArray addObject:cell.friendName.text];
        NSString *str = snapshot.value[@"image"];
        NSURL * url = [NSURL URLWithString:str];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.friendImage.image = [UIImage imageWithData:data];
    }];
    cell.messageBtn.tag = indexPath.row;
    [cell.messageBtn addTarget:self action:@selector(messageRequest:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}



-(void)messageRequest:(UIButton *)sender {
    
    self.receiveID = [[self.friendArray objectAtIndex:sender.tag]valueForKey:@"friendId"];
    self.receiveName =[self.friendNameArray objectAtIndex:sender.tag] ;
    ChatViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    [controller setReceiveId:self.receiveID];
    [controller setReceiveName:self.receiveName];
    [controller setSenderName:self.currentUserName];
    
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
