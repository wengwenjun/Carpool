//
//  ChatViewController.h
//  Carpool
//
//  Created by Wenjun Weng on 5/4/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "ViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
@import Firebase;

@interface ChatViewController : JSQMessagesViewController
@property (nonatomic) NSString *receiveId;
@property (nonatomic) NSString *receiveName;
@property (nonatomic) NSString * senderName;
@end
