//
//  MyProfileViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/4/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "MyProfileViewController.h"
#import "MyProfileTableViewCell.h"
#import "RatingViewController.h"
@import Firebase;
@interface MyProfileViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic) FIRDatabaseReference *ref;
@property  (nonatomic) NSMutableArray *notifyArray;
@property (nonatomic) NSString *passengerID;
@property (nonatomic)NSString *driverID;
@property (nonatomic) NSString*currentUserID;
@property (nonatomic) NSMutableArray *postArray;

@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Carpool History";
    self.ref = [[FIRDatabase database]reference];
    self.notifyArray = [[NSMutableArray alloc]init];
    self.postArray = [[NSMutableArray alloc]init];
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //self.tblView.estimatedRowHeight = 350;
    //self.tblView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
    [self readAllNofication];
}

-(void)readAllNofication{
    FIRUser *currentUser = [[FIRAuth auth]currentUser];
    self.currentUserID = currentUser.uid;
    FIRDatabaseQuery *allNotify = [[self.ref child:@"carpoolHistory"]queryOrderedByKey];
    [allNotify observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *child in snapshot.children){
            NSLog(@"%@",child.value[@"acceptStatus"]);
            BOOL isequal = [self.currentUserID isEqualToString:child.value[@"passengerID"]]||[self.currentUserID isEqualToString:child.value[@"driverID"]] ;
            if([child.value[@"acceptStatus"]  isEqual: @1]&& isequal){
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:child.value];
                dict[@"requestID"] = child.key;
                NSLog(@"%@",dict);
                [self.notifyArray addObject:dict];
                [self.tblView reloadData];
            }
        }
    
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [self.notifyArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyProfileTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"MyProfileTableViewCell" forIndexPath:indexPath];
    NSString *postID = [[self.notifyArray objectAtIndex:indexPath.row]objectForKey:@"postID"];
    [self.postArray addObject:postID];
    FIRDatabaseQuery *post = [[self.ref child:@"posts"]child:postID];
    [post observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.key);
        NSLog(@"%@",snapshot.value);
        cell.driverDepatureTime.text = snapshot.value[@"depatureTime"];
        cell.driverStartLocation.text = snapshot.value[@"pickupLocation"];
        cell.driverDestination.text = snapshot.value[@"destinationLocation"];
        self.driverID = snapshot.value[@"id"];
        if([self.currentUserID isEqualToString:self.driverID]){
            [cell.endTrip setHidden:YES];
        }
        FIRDatabaseQuery *allUsers = [[self.ref child:@"publicUsers"]child:self.driverID];
        [allUsers observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            cell.driverName.text = snapshot.value[@"name"];
            NSString *str = snapshot.value[@"image"];
            NSURL * url = [NSURL URLWithString:str];
            NSData *data = [NSData dataWithContentsOfURL:url];
            cell.driverImageView.image = [UIImage imageWithData:data];
        }];
    }];

    NSString *requestID = [[self.notifyArray objectAtIndex:indexPath.row]objectForKey:@"requestID"];
   FIRDatabaseQuery *request = [[self.ref child:@"requests"]child:requestID];
    [request observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.key);
        NSLog(@"%@",snapshot.value);
        cell.passengerDepatureTime.text = snapshot.value[@"depatureTime"];
        cell.passengerStartLocation.text = snapshot.value[@"pickupLocation"];
        cell.passengerDestination.text = snapshot.value[@"destinationLocation"];
        self.passengerID = snapshot.value[@"id"];
        FIRDatabaseQuery *allUsers = [[self.ref child:@"publicUsers"]child:self.passengerID];
        [allUsers observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            cell.passengerName.text = snapshot.value[@"name"];
            NSString *str = snapshot.value[@"image"];
            NSURL * url = [NSURL URLWithString:str];
            NSData *data = [NSData dataWithContentsOfURL:url];
            cell.passengerImageView.image = [UIImage imageWithData:data];
        }];
    }];
    cell.endTrip.tag = indexPath.row;
    [cell.endTrip addTarget:self action:@selector(endTripClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
-(void) endTripClicked: (UIButton *)sender{
    NSString *postID = [self.postArray objectAtIndex:sender.tag];
    RatingViewController *rateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RatingViewController"];
    [rateVC setPostID:postID];
    [self.navigationController pushViewController:rateVC animated:YES];

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
