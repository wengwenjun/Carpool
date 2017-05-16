//
//  AppDelegate.h
//  Carpool
//
//  Created by Wenjun Weng on 4/27/17.
//  Copyright © 2017 rjt. All rights reserved.
//
//login in: username: rebecca@hotmail.com; password:123456

#import <UIKit/UIKit.h>
@import GoogleSignIn;
@import Firebase;
#import <FBSDKButton.h>
#import <FBSDKCoreKit.h>

#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) NSString *strDeviceToken;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *requestID;


@end

