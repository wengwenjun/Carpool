//
//  AppDelegate.m
//  Carpool
//
//  Created by Wenjun Weng on 4/27/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "AppDelegate.h"
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()
@property (nonatomic) FIRDatabaseReference* ref;
@property (nonatomic) NSString* refreshedToken;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FIRApp configure];
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [self registerForRemoteNotification];
    self.ref = [[FIRDatabase database]reference];
    self.refreshedToken = [[FIRInstanceID instanceID] token];
    [[NSUserDefaults standardUserDefaults]setObject:self.refreshedToken  forKey:@"instanceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (void)application:(UIApplication *)application
performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
  completionHandler:(void (^)(BOOL succeeded))completionHandler{
    if([shortcutItem.type isEqualToString: @"com.mycompany.myapp.openfavorites"]){
        UIViewController *notificationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
        [self.window.rootViewController presentViewController:notificationVC animated:YES completion:nil];
        completionHandler(true);
    }else if([shortcutItem.type isEqualToString:@"com.mycompany.myapp.newmessage"]){
        UIViewController *notificationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"passenegerViewController"];
        [self.window.rootViewController presentViewController:notificationVC animated:YES completion:nil];
        completionHandler(true);
    }else{
    completionHandler(false);
    }
}
- (BOOL)application:(nonnull UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *, id> *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]||[[FBSDKApplicationDelegate sharedInstance]application:application openURL:url options:options];
}


- (void)application:(UIApplication* )application didRegisterUserNotificationSettings:(UIUserNotificationSettings* )notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication* )application didRegisterForRemoteNotificationsWithDeviceToken:(NSData* )deviceToken{
    NSString *strDevicetoken = [[NSString alloc]initWithFormat:@"%@",[[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    NSLog(@"Device Token = %@",strDevicetoken);
    self.strDeviceToken = strDevicetoken;
    //NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", self.refreshedToken);
   // FIRUser *currentUser = [[FIRAuth auth]currentUser];
    //[[[self.ref child:@"publicUsers"]child:currentUser.uid]   updateChildValues:@{@"instanceID": self.refreshedToken}];
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken
                                        type:FIRInstanceIDAPNSTokenTypeSandbox];
}

-(void)application:(UIApplication* )application didReceiveRemoteNotification:(NSDictionary* )userInfo
{
    NSLog(@"Push Notification Information : %@",userInfo);
}

-(void)application:(UIApplication* )application didFailToRegisterForRemoteNotificationsWithError:(NSError* )error
{
    NSLog(@"%@ = %@", NSStringFromSelector(_cmd), error);
    NSLog(@"Error = %@",error);
}

#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10

- (void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSLog(@"User Info = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter* )center didReceiveNotificationResponse:(UNNotificationResponse* )response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"User Info = %@",response.notification.request.content.userInfo);
    self.requestID = response.notification.request.content.userInfo[@"rideInfo"];
    UIViewController *notificationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    [[NSUserDefaults standardUserDefaults]setObject:self.requestID forKey:@"requestID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.window.rootViewController presentViewController:notificationVC animated:YES completion:nil];
    completionHandler();
}

#pragma mark - Class Methods

/**
 Notification Registration
 */
- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
        [FIRMessaging messaging].remoteMessageDelegate = self;
    }
    else {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    // [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
