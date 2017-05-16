//
//  SignInViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 4/27/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "SignInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@interface SignInViewController () <FBSDKLoginButtonDelegate,GIDSignInDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginBtn;
@property(nonatomic) NSString *pictureURL;
@property(nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic)NSString *instanceID;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = YES;
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    self.fbLoginBtn.readPermissions = @[@"public_profile", @"email"];
    self.fbLoginBtn.delegate = self;
    self.ref = [[FIRDatabase database]reference];
    self.instanceID = [[NSUserDefaults standardUserDefaults]objectForKey:@"instanceToken"];
    
    // Do any additional setup after loading the view.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailTextField  resignFirstResponder];
    [self.passwordTextField  resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    return YES;
}

//email login
- (IBAction)signInBtnAction:(id)sender {
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(error == nil){
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolListViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            NSLog(@"%@",error.localizedDescription);
        }
    }];
    
}
//google login
- (IBAction)signBtnAction:(id)sender {
     [[GIDSignIn sharedInstance] signIn];
}
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // ...
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if(error){
                NSLog(@"%@",error.localizedDescription);
            }else{
                NSString *userId = user.uid;
                NSString *fullname =user.displayName;
                NSString *email = user.email;
                NSString *providerId = credential.provider;
                NSURL *imageurl = user.photoURL;
                NSString *image = [NSString stringWithFormat:@"%@",imageurl];
                [[[self.ref child:@"users"]child:user.uid]updateChildValues:@{@"id":userId,@"name":fullname,@"email":email, @"provider":providerId,@"image":image}];
                [[[self.ref child:@"publicUsers"]child:user.uid]updateChildValues:@{@"name": fullname, @"image":image, @"instanceID":self.instanceID}];
                UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolListViewController"];
                [self.navigationController pushViewController:controller animated:YES];
            }
        }];
        // ...
    } else {
        // ...
    }
}
//google logout
- (IBAction)signOutBtnAction:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }
    
}
//facebook login
- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    if (error == nil) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if(error){
                NSLog(@"%@", error.localizedDescription);
            }else{
                if([FBSDKAccessToken currentAccessToken]){
                    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                    [parameters setValue:@"id,name,email" forKey:@"fields"];
                    [[[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:parameters] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)result];
                        self.pictureURL = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",[dict valueForKey:@"id"]];
                        [dict setValue:credential.provider forKey:@"provider"];
                        [dict setValue:self.pictureURL forKey:@"image"];
                        [dict setObject:self.instanceID forKey:@"instanceID"];
                        //[dict setValue:self.instanceID forKey:@"instanceID"];
                        if(error == nil){
                            [[[self.ref child:@"users"]child:user.uid]updateChildValues:dict];
                            [[[self.ref child:@"publicUsers"]child:user.uid]updateChildValues:@{@"name": [dict valueForKey:@"name"], @"image": self.pictureURL}];
                            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolListViewController"];
                            [self.navigationController pushViewController:controller animated:YES];
                        }else{
                            NSLog(@"%@",error.localizedDescription);
                        }
                    }];
                }
            }
        }];
        
    } else {
        NSLog(@"%@",error.localizedDescription);
    }
}

//facebook loginout
-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
