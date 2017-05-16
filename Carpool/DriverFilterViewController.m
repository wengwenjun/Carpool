//
//  DriverFilterViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/1/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "DriverFilterViewController.h"
@import Firebase;
#import "driverTableViewCell.h"

@interface DriverFilterViewController ()
@property (nonatomic) FIRDatabaseReference *geofireRef;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) NSMutableArray *passengerArray;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@end

@implementation DriverFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Nearby Requests";
    // Do any additional setup after loading the view.
    self.tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.geofireRef = [[[FIRDatabase database]reference]child:@"passengerLocation"];
    self.ref = [[FIRDatabase database]reference];
    self.passengerArray = [[NSMutableArray alloc]init];
    [self sortNearby];
}

-(void)sortNearby {
    GeoFire *geofire = [[GeoFire alloc]initWithFirebaseRef:self.geofireRef];
    GFCircleQuery *circleQuery = [geofire queryAtLocation:self.startlocation withRadius:5];
    FIRDatabaseQuery *allPosts = [self.ref child:@"requests"];
    [circleQuery observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        NSLog(@"Key '%@' entered the search area and is at location '%@'", key, location);
        [allPosts observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            for(FIRDataSnapshot *child in [snapshot children]){
                NSLog(@"%@", child.key);
                if([key isEqualToString: child.key]){
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:child.value];
                    dict[@"passengerId"] = child.key;
                    [self.passengerArray addObject:dict];
                    [self.tblView reloadData];
                }
            }
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  [self.passengerArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    driverTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"driverTableViewCell" forIndexPath:indexPath];
    cell.passengerStartLocation.text =[[self.passengerArray objectAtIndex:indexPath.row]valueForKey:@"pickupLocation"];
    cell.passengerDestination.text = [[self.passengerArray objectAtIndex:indexPath.row]valueForKey:@"destinationLocation"];
    cell.passenegerDepatureTime.text = [[self.passengerArray objectAtIndex:indexPath.row]valueForKey:@"depatureTime"];
    NSString *passenegerID = [[self.passengerArray objectAtIndex:indexPath.row]valueForKey:@"id"];
    FIRDatabaseQuery *allUsers = [[self.ref child:@"publicUsers"]child:passenegerID];
    [allUsers observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        cell.passengerName.text = snapshot.value[@"name"];
        NSString *str = snapshot.value[@"image"];
        NSURL * url = [NSURL URLWithString:str];
        NSData *data = [NSData dataWithContentsOfURL:url];
        cell.passengerImage.image = [UIImage imageWithData:data];
    }];
    //cell.acceptButton.tag = indexPath.row;
    
    //[cell.acceptButton addTarget:self action:@selector(acceptARide:) forControlEvents:UIControlEventTouchUpInside];
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
