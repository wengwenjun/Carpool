//
//  FriendListTableViewCell.h
//  Carpool
//
//  Created by Wenjun Weng on 5/7/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;

@end
