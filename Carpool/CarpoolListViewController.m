//
//  CarpoolListViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 4/29/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "CarpoolListViewController.h"
@import Firebase;
#import "CarpoolListTableViewCell.h"
#import <CoreLocation/CoreLocation.h>
#import <GeoFire.h>

@interface CarpoolListViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *currentLocation;
@property (nonatomic) FIRDatabaseReference *geofireRef;
@property (nonatomic) NSMutableArray *driverArray;
@end

@implementation CarpoolListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Nearby Carpool";
    // Do any additional setup after loading the view.
    self.ref = [[FIRDatabase database]reference];
     self.geofireRef = [[[FIRDatabase database]reference]child:@"driverLocation"];
    self.driverArray = [[NSMutableArray alloc]init];
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tblView.estimatedRowHeight = 131;
    self.tblView.rowHeight = UITableViewAutomaticDimension;
    if(self.sortingBtn.tag ==0){
    [self setupLocation];
    }else{
        [self sortByTime];
    }
}
-(void) setupLocation{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    self.currentLocation = self.locationManager.location;
    [self findAllPosts];
}


-(void) findAllPosts{
    GeoFire *geofire = [[GeoFire alloc]initWithFirebaseRef:self.geofireRef];
    GFCircleQuery *circleQuery = [geofire queryAtLocation:self.currentLocation withRadius:5];
    NSLog(@"%@",self.currentLocation);
    FIRDatabaseQuery *allPosts = [self.ref child:@"posts"];
    [circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
       // NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        [allPosts observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            for(FIRDataSnapshot *child in [snapshot children]){
                //NSLog(@"%@", child.key);
                if([key isEqualToString: child.key]){
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:child.value];
                    dict[@"driverId"] = child.key;
                    [self.driverArray addObject:dict];
                    [self.tblView reloadData];
                }
            }
        }];
    }];
}

-(void)sortByTime{
    FIRDatabaseQuery *query = [[self.ref child:@"posts"]queryOrderedByChild:@"depatureTime"];
    [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        for(FIRDataSnapshot *child in [snapshot children]){
        NSMutableDictionary * dict= [NSMutableDictionary dictionaryWithDictionary:snapshot.value];
        dict[@"driverId"] = child.key;
        [self.driverArray addObject:dict];
        [self.tblView reloadData];
        }
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.driverArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CarpoolListTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"CarpoolListTableViewCell"];
    cell.driverCarModel.text = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"carModel"];
    cell.driverStartLocation.text =[[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"pickupLocation"];
    cell.driverDestination.text = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"destinationLocation"];
    cell.driverDepatureTime.text = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"depatureTime"];
    NSString *driverID = [[self.driverArray objectAtIndex:indexPath.row]valueForKey:@"id"];
    FIRDatabaseQuery *allUsers = [[self.ref child:@"publicUsers"]child:driverID];
    [allUsers observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        cell.driverName.text = snapshot.value[@"name"];
        NSString *str = snapshot.value[@"image"];
        NSURL * url = [NSURL URLWithString:str];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.driverImage.image = [UIImage imageWithData:data];
    }];
    return cell;
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
