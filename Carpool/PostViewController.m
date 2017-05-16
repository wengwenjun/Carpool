//
//  PostViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 4/29/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "PostViewController.h"
@import Firebase;
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GeoFire.h>
#import "DriverFilterViewController.h"

@interface PostViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pickupLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UITextField *departureTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *carModelTextField;
@property (weak, nonatomic) IBOutlet UITextField *carColorTextField;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) NSMutableString *address;
@property (nonatomic)FIRDatabaseReference *geoFireRef;
@property (nonatomic)CLLocation *location;
@property (nonatomic)CLLocation *startLocation;
@property (nonatomic)CLLocation *finishLocation;


@end

BOOL flag;
@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ref = [[FIRDatabase database]reference];
    self.geoFireRef = [[[FIRDatabase database]reference]child:@"driverLocation"];
    self.departureTimeTextField.text = self.scheduleTime;
    [self.pickupLocationTextField addTarget:self action:@selector(pickup) forControlEvents:UIControlEventEditingDidBegin];
    [self.destinationTextField addTarget:self action:@selector(destination) forControlEvents:UIControlEventEditingDidBegin];
    
    //[self setupLocation];
    
}
-(void) pickup{
    [self.view endEditing:YES];
    flag = YES;
    [self setupLocation];
    
}
-(void)destination{
    [self.view endEditing:YES];
    flag = NO;
    [self setupLocation];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.pickupLocationTextField  resignFirstResponder];
    [self.destinationTextField  resignFirstResponder];
    [self.departureTimeTextField  resignFirstResponder];
    [self.carModelTextField  resignFirstResponder];
    [self.carColorTextField resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.pickupLocationTextField) {
        [self.destinationTextField becomeFirstResponder];
    }
    else if (textField == self.destinationTextField) {
        [self.departureTimeTextField becomeFirstResponder];
    }
    else if (textField == self.departureTimeTextField) {
        [self.carModelTextField becomeFirstResponder];
    }
    else if (textField == self.carModelTextField){
        [self.carColorTextField resignFirstResponder];
    }
    
    return YES;
    
}

-(void) setupLocation{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    [self.mapView setDelegate:self];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = [locations lastObject];
    if(location !=nil) {
        NSLog(@"%@",location);
        MKPointAnnotation * mapPin = [[MKPointAnnotation alloc]init];
        //mapPin.title = @"Address";
        mapPin.coordinate = location.coordinate;
        MKCoordinateRegion region = self.mapView.region;
        region.center = location.coordinate;
        region.span.latitudeDelta =0.03;
        region.span.longitudeDelta =0.03;
        [self.mapView setRegion: region];
        for (id annotation in self.mapView.annotations){
            [self.mapView removeAnnotation:annotation];
        }
        [self.mapView addAnnotation:mapPin];
        [self.locationManager stopUpdatingLocation];
    }
}
- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"] ;
    }else
        {
            pin.annotation = annotation;
        }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    return pin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        [annotationView.annotation setCoordinate:droppedAt];
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        self.location = [[CLLocation alloc]initWithLatitude: droppedAt.latitude longitude:droppedAt.longitude];
        if(flag){
            self.startLocation = self.location;
        }else {
            self.finishLocation = self.location;
        }
        [self reverGeoCoding:self.location];
    }
    
}

-(void) reverGeoCoding :(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *place= [placemarks lastObject];
        //NSLog(@"%@",place.addressDictionary);
        //self.address = [place.addressDictionary objectForKey:@"FormattedAddressLines"];
        self.address = [[NSMutableString alloc]init];
        [self.address appendFormat:@" %@, %@, %@, %@",[place.addressDictionary objectForKey:@"Street"],[place.addressDictionary objectForKey:@"City"],[place.addressDictionary objectForKey:@"State"],[place.addressDictionary objectForKey:@"ZIP"] ];
        if(flag){
            self.pickupLocationTextField.text = self.address;
        }else{
            self.destinationTextField.text = self.address;
        }
    }];
}


- (IBAction)postBtnAction:(id)sender {
    FIRUser *currenUser = [[FIRAuth auth]currentUser];
    FIRDatabaseReference *driverPostRef = [[self.ref child:@"posts"]childByAutoId];
    NSString *driverID = driverPostRef.key;
    [driverPostRef updateChildValues:@{@"id": currenUser.uid,@"pickupLocation": self.pickupLocationTextField.text, @"destinationLocation": self.destinationTextField.text, @"depatureTime":self.departureTimeTextField.text, @"carModel": self.carModelTextField.text, @"carColor": self.carColorTextField.text}];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:self.geoFireRef];
    [geoFire setLocation:self.startLocation forKey:driverID];
    //[geoFire setLocation:self.finishLocation forKey:driverID];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DriverFilterViewController *df = [segue destinationViewController];
    [df setStartlocation:self.startLocation];
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
