//
//  passengerTableViewCell.h
//  Carpool
//
//  Created by Wenjun Weng on 5/1/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface passengerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *driverImage;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *driverCarModel;
@property (weak, nonatomic) IBOutlet UILabel *driverDepartureTime;
@property (weak, nonatomic) IBOutlet UILabel *driverStartLocation;
@property (weak, nonatomic) IBOutlet UILabel *driverDestination;
@property (weak, nonatomic) IBOutlet UIButton *requestButton;

@end
