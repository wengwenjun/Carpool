//
//  PassengerFilterViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/1/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "PassengerFilterViewController.h"
@import Firebase;
#import <GeoFire.h>
#import "passengerTableViewCell.h"


@interface PassengerFilterViewController ()
@property (nonatomic) FIRDatabaseReference *geofireRef;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) NSMutableArray *driverArray;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic)FIRUser * currentUser;
@property (nonatomic) NSString *sampleFireInstanceToken;

@end

@implementation PassengerFilterViewController
@synthesize requestID = _requestID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Nearby Carpool";
    self.geofireRef = [[[FIRDatabase database]reference]child:@"driverLocation"];
    self.ref = [[FIRDatabase database]reference];
    self.driverArray = [[NSMutableArray alloc]init];
    self.currentUser = [[FIRAuth auth]currentUser];
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self sortNearby];
}

-(void)sortNearby {
    GeoFire *geofire = [[GeoFire alloc]initWithFirebaseRef:self.geofireRef];
    GFCircleQuery *circleQuery = [geofire queryAtLocation:self.startLocation withRadius:5];
    FIRDatabaseQuery *allPosts = [self.ref child:@"posts"];
    [circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        [allPosts observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            for(FIRDataSnapshot *child in [snapshot children]){
                NSLog(@"%@", child.key);
                if([key isEqualToString: child.key]){
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:child.value];
                    dict[@"postID"] = child.key;
                    [self.driverArray addObject:dict];
                    [self.tblView reloadData];
                }
            }
            
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [self.driverArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    passengerTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"passengerTableViewCell" forIndexPath:indexPath];
    cell.driverCarModel.text = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"carModel"];
    cell.driverStartLocation.text =[[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"pickupLocation"];
    cell.driverDestination.text = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"destinationLocation"];
    cell.driverDepartureTime.text = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"depatureTime"];
    NSString *driverID = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"id"];
    FIRDatabaseQuery *allUsers = [[self.ref child:@"publicUsers"]child:driverID];
    [allUsers observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        cell.driverName.text = snapshot.value[@"name"];
        NSString *str = snapshot.value[@"image"];
        NSURL * url = [NSURL URLWithString:str];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.driverImage.image = [UIImage imageWithData:data];
    }];
    //postid, driverid, passengerid, pendingstatus
    cell.requestButton.tag = indexPath.row;
    [cell.requestButton addTarget:self action:@selector(requestARide:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void) requestARide: (UIButton *)sender{
    sender.backgroundColor = [UIColor blueColor];
    NSString * postID = [[self.driverArray objectAtIndex:sender.tag]valueForKey:@"postID"];
    NSString * driverID = [[self.driverArray objectAtIndex: sender.tag]valueForKey:@"id"];
    [[[self.ref child:@"carpoolHistory"]child:self.requestID]updateChildValues:@{@"postID": postID, @"driverID": driverID, @"passengerID": self.currentUser.uid, @"acceptStatus":@NO}];
    FIRDatabaseReference * allUsers = [[self.ref child:@"publicUsers"]child:driverID];
    [allUsers observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"%@",snapshot.key);
        NSLog(@"%@",snapshot.value);
        self.sampleFireInstanceToken = snapshot.value[@"instanceID"];
        NSDictionary *notificationDict = @{
                                           @"username": self.sampleFireInstanceToken,
                                           @"message" : @"You got a ride request!",
                                           @"rideinfo" : self.requestID
                                           };
        
        [[[self.ref child:@"notificationRequests"]childByAutoId]updateChildValues:notificationDict];
    }];
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
