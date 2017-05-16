//
//  NotificationViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/3/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
#import "ChatViewController.h"
@import Firebase;

@interface NotificationViewController ()
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) NSMutableArray * postArray;
@property (nonatomic) NSString *passengerID;
@property (nonatomic) NSString *passengerName;
@property (nonatomic) NSString *driverName;
@property (weak, nonatomic) IBOutlet UIImageView *passengerImageView;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passengerDepatureTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *passenegerStartLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *passengerDestinationLocationLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

BOOL isconfirm;
@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Your Pending Request";
    self.ref = [[FIRDatabase database]reference];
    self.postArray = [[NSMutableArray alloc]init];
    self.requestID = [[NSUserDefaults standardUserDefaults]objectForKey:@"requestID"];
    NSString* currentUserID = [[FIRAuth auth]currentUser].uid;
    FIRDatabaseQuery *currentUser = [[self.ref child:@"publicUsers"]child:currentUserID];
    [currentUser observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.driverName = snapshot.value[@"name"];
    }];
    FIRDatabaseQuery *request = [self.ref child:@"requests"];
    [request observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *child in snapshot.children){
            if([child.key isEqualToString: self.requestID]){
                self.passengerDepatureTimeLabel.text = child.value[@"depatureTime"];
                 self.passenegerStartLocationLabel.text= child.value[@"pickupLocation"];
                self.passengerDestinationLocationLabel.text= child.value[@"destinationLocation"];
                self.passengerID = child.value[@"id"];
            }
        }
    }];
    FIRDatabaseQuery *passengerInfo = [self.ref child:@"publicUsers"];
    [passengerInfo observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *child in snapshot.children){
            if([child.key isEqualToString:self.passengerID]){
                self.passengerName = child.value[@"name"];
                self.passengerNameLabel.text = self.passengerName;
                NSString *str = child.value[@"image"];
                NSURL * url = [NSURL URLWithString:str];
                NSData *data = [NSData dataWithContentsOfURL:url];
                self.passengerImageView.image = [UIImage imageWithData:data];
            }
        }
    }];
    //[self readallRequest];
    // Do any additional setup after loading the view.
}


- (IBAction)confirmBtnClicked:(UIButton *)sender {
    sender.backgroundColor = [UIColor lightGrayColor];
    //sender.imageView.image = [UIImage imageNamed:@"Happy-50.png"];
    NSString* currentUserID = [[FIRAuth auth]currentUser].uid;
     [[[self.ref child:@"carpoolHistory"]child:self.requestID]updateChildValues:@{@"acceptStatus": @YES}];
    //[[[[[self.ref child: @"publicUsers"]child:currentUserID] child:@"friendList"]child:self.passengerID]setValue:@"True"];
    [[[[self.ref child:@"publicUsers"]child:currentUserID]child:@"friendList"]updateChildValues:@{self.passengerID: @"True"}];
     //[[[[[self.ref child: @"publicUsers"]child:self.passengerID] child:@"friendList"]child:currentUserID]setValue:@"True"];
    [[[[self.ref child:@"publicUsers"]child:self.passengerID]child:@"friendList"]updateChildValues:@{currentUserID: @"True"}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ChatViewController *chatVC = [segue destinationViewController];
    [chatVC setSenderName:self.driverName];
    [chatVC setReceiveId:self.passengerID];
    [chatVC setReceiveName:self.passengerName];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationTableViewCell" forIndexPath:indexPath];
    FIRDatabaseQuery *request = [self.ref child:@"requests"];
    [request observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *child in snapshot.children){
            if([child.key isEqualToString: self.requestID]){
                cell.passengerDepatureTime.text = child.value[@"depatureTime"];
                cell.passengerStartLocation.text = child.value[@"pickupLocation"];
                cell.passenegerDestination.text = child.value[@"destinationLocation"];
                self.passengerID = child.value[@"id"];
            }
        }
    }];
    FIRDatabaseQuery *passengerInfo = [self.ref child:@"publicUsers"];
    [passengerInfo observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *child in snapshot.children){
            if([child.key isEqualToString:self.passengerID]){
                self.passengerName = child.value[@"name"];
                cell.passengerName.text = self.passengerName;
                NSString *str = child.value[@"image"];
                NSURL * url = [NSURL URLWithString:str];
                NSData *data = [NSData dataWithContentsOfURL:url];
                cell.passengerImage.image = [UIImage imageWithData:data];
            }
        }
    }];
    
    [cell.confirmButton addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
