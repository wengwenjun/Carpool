//
//  CarpoolListTableViewCell.h
//  Carpool
//
//  Created by Wenjun Weng on 4/29/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarpoolListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *driverImage;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet UILabel *driverCarModel;
@property (weak, nonatomic) IBOutlet UILabel *driverDepatureTime;
@property (weak, nonatomic) IBOutlet UILabel *driverStartLocation;
@property (weak, nonatomic) IBOutlet UILabel *driverDestination;

@end
