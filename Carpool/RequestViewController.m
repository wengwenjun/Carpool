//
//  RequestViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/1/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "RequestViewController.h"
@import Firebase;
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GeoFire.h"
#import "PassengerFilterViewController.h"


@interface RequestViewController ()<UITextFieldDelegate, MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pickupTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UITextField *departureTimeTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) BOOL flagname;
@property (nonatomic) CLLocationManager *manager;
@property (nonatomic) NSMutableString *addressString;
@property (nonatomic)FIRDatabaseReference *geoFireRef;
@property(nonatomic) CLLocation *location;
@property(nonatomic) CLLocation *startLocation;
@property(nonatomic) CLLocation *finishLocation;
@property(nonatomic) FIRUser *currentUser;
@property(nonatomic) FIRDatabaseReference * passengerRequestRef;

@end

NSString *requestID;
@implementation RequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    self.departureTimeTextField.text = self.scheduleTime;
    [self.pickupTextField addTarget:self action:@selector(pickup) forControlEvents:UIControlEventEditingDidBegin];
    [self.destinationTextField addTarget:self action:@selector(dropoff) forControlEvents:UIControlEventEditingDidBegin];
    self.geoFireRef =[[[FIRDatabase database]reference]child:@"passengerLocation"];
    self.currentUser = [[FIRAuth auth]currentUser];
    self.passengerRequestRef = [[self.ref child:@"requests"]childByAutoId];
    requestID= self.passengerRequestRef.key;
    // Do any additional setup after loading the view.
}

-(void) pickup{
    [self.view endEditing: YES];
    self.flagname = YES;
    [self setupLocation];
}

-(void) dropoff{
    [self.view endEditing: YES];
    self.flagname = NO;
    [self setupLocation];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.pickupTextField  resignFirstResponder];
    [self.destinationTextField  resignFirstResponder];
    [self.departureTimeTextField  resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.pickupTextField) {
        [self.destinationTextField becomeFirstResponder];
    }
    else if (textField == self.destinationTextField) {
        [self.departureTimeTextField becomeFirstResponder];
    }
    return YES;
}

-(void) setupLocation{
    self.manager = [[CLLocationManager alloc]init];
    self.manager.delegate = self;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.manager requestAlwaysAuthorization];
    [self.manager requestWhenInUseAuthorization];
    [self.manager startUpdatingLocation];
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
        [self.manager stopUpdatingLocation];
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
        // NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
        
        self.location = [[CLLocation alloc]initWithLatitude: droppedAt.latitude longitude:droppedAt.longitude];
        if(self.flagname){
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
        self.addressString = [[NSMutableString alloc]init];
        [self.addressString appendFormat:@" %@, %@, %@, %@",[place.addressDictionary objectForKey:@"Street"],[place.addressDictionary objectForKey:@"City"],[place.addressDictionary objectForKey:@"State"],[place.addressDictionary objectForKey:@"ZIP"] ];
        if(self.flagname){
            self.pickupTextField.text = self.addressString;
        }else{
            self.destinationTextField.text = self.addressString;
        }
    }];
}
- (IBAction)requireBtnAction:(id)sender {
 
    
    [self.passengerRequestRef updateChildValues:@{@"id": self.currentUser.uid,@"pickupLocation": self.pickupTextField.text, @"destinationLocation": self.destinationTextField.text, @"depatureTime":self.departureTimeTextField.text}];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:self.geoFireRef];
    [geoFire setLocation:self.startLocation forKey:requestID];
    //[geoFire setLocation:self.finishLocation forKey:driverID];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PassengerFilterViewController *pf = [segue destinationViewController];
    [pf setStartLocation:self.startLocation];
    [pf setRequestID:requestID];
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
