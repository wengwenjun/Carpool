//
//  driverTableViewCell.h
//  Carpool
//
//  Created by Wenjun Weng on 5/2/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface driverTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *passengerImage;
@property (weak, nonatomic) IBOutlet UILabel *passengerName;
@property (weak, nonatomic) IBOutlet UILabel *passenegerDepatureTime;
@property (weak, nonatomic) IBOutlet UILabel *passengerStartLocation;
@property (weak, nonatomic) IBOutlet UILabel *passengerDestination;

@end
