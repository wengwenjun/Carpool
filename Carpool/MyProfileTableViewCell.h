//
//  MyProfileTableViewCell.h
//  Carpool
//
//  Created by Wenjun Weng on 5/4/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSStarRatingView.h"

@interface MyProfileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *passengerImageView;
@property (weak, nonatomic) IBOutlet UILabel *passengerName;
@property (weak, nonatomic) IBOutlet UILabel *passengerDepatureTime;
@property (weak, nonatomic) IBOutlet UILabel *passengerStartLocation;
@property (weak, nonatomic) IBOutlet UILabel *passengerDestination;
@property (weak, nonatomic) IBOutlet UIImageView *driverImageView;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *driverDepatureTime;
@property (weak, nonatomic) IBOutlet UILabel *driverStartLocation;
@property (weak, nonatomic) IBOutlet UILabel *driverDestination;
@property (weak, nonatomic) IBOutlet UIButton *endTrip;

@end
