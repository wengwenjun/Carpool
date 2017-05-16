//
//  SignUpViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 4/29/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "SignUpViewController.h"
@import Firebase;
#import "CarpoolListViewController.h"

@interface SignUpViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) NSString *instanceID;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ref = [[FIRDatabase database]reference];
    //self.instanceID = [[NSUserDefaults standardUserDefaults]objectForKey:@"instanceID"];
    self.instanceID = [[NSUserDefaults standardUserDefaults]objectForKey:@"instanceToken"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.emailTextField  resignFirstResponder];
    [self.passwordTextField  resignFirstResponder];
    [self.nameTextField  resignFirstResponder];
    [self.ageTextField  resignFirstResponder];
    [self.addressTextField  resignFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordTextField) {
        [self.nameTextField becomeFirstResponder];
    }
    else if (textField == self.nameTextField) {
        [self.ageTextField becomeFirstResponder];
    }
    else if (textField == self.ageTextField) {
        [self.addressTextField becomeFirstResponder];
    }
    else if (textField == self.addressTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    return YES;
}

- (IBAction)signUpBtnAction:(id)sender {
    [[FIRAuth auth] createUserWithEmail: self.emailTextField.text password:self.passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(error == nil){
            NSLog(@"%@", user.uid);
            [[FIRAuth auth].currentUser sendEmailVerificationWithCompletion:^(NSError * _Nullable error) {
                NSLog(@"Send email Successfully!");
            }];
            NSString *str = @"https://assets-cdn.github.com/images/modules/logos_page/Octocat.png";
            [[[self.ref child:@"users"]child:user.uid]updateChildValues: @{@"email":self.emailTextField.text, @"password":self.passwordTextField.text, @"name":self.nameTextField.text, @"age":self.ageTextField.text, @"address": self.addressTextField.text, @"image": str, @"provider":user.providerID}];
            if(self.instanceID == nil){
                  [[[self.ref child:@"publicUsers"]child:user.uid]updateChildValues:@{@"name": self.nameTextField.text, @"age":self.ageTextField.text, @"address": self.addressTextField.text, @"image": str}];
            }else{
            [[[self.ref child:@"publicUsers"]child:user.uid]updateChildValues:@{@"name": self.nameTextField.text, @"age":self.ageTextField.text, @"address": self.addressTextField.text, @"image": str,@"instanceID":self.instanceID}];
            }
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolListViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [[FIRAuth auth] signInWithEmail:self.nameTextField.text password:self.passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if(error == nil){
            UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CarpoolListViewController"];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else{
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
