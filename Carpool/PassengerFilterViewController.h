//
//  PassengerFilterViewController.h
//  Carpool
//
//  Created by Wenjun Weng on 5/1/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface PassengerFilterViewController : UIViewController
@property (nonatomic) CLLocation* startLocation;
@property (nonatomic) NSString *requestID;
@end
