//
//  NotificationTableViewCell.h
//  Carpool
//
//  Created by Wenjun Weng on 5/3/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *passengerImage;
@property (weak, nonatomic) IBOutlet UILabel *passengerName;
@property (weak, nonatomic) IBOutlet UILabel *passengerDepatureTime;
@property (weak, nonatomic) IBOutlet UILabel *passengerStartLocation;
@property (weak, nonatomic) IBOutlet UILabel *passenegerDestination;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@end
