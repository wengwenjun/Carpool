//
//  RatingViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/5/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "RatingViewController.h"
@import Firebase;
#import "HCSStarRatingView.h"

@interface RatingViewController ()
@property (nonatomic) FIRDatabaseReference * ref;
@property (weak, nonatomic) IBOutlet UIImageView *driverImageView;
@property (weak, nonatomic) IBOutlet UILabel *driverName;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *rateValue;
@property (weak, nonatomic) IBOutlet UILabel *driverDepTime;
@property (weak, nonatomic) IBOutlet UILabel *driverStartLocation;
@property (weak, nonatomic) IBOutlet UILabel *driverDestination;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Rate Your Carpool";
    self.ref = [[FIRDatabase database]reference];
    FIRDatabaseQuery *currentCarpool = [[self.ref child:@"posts"]child:self.postID];
    [currentCarpool observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.driverDepTime.text = snapshot.value[@"depatureTime"];
        self.driverStartLocation.text = snapshot.value[@"pickupLocation"];
        self.driverDestination.text = snapshot.value[@"destinationLocation"];
        NSString *driverID = snapshot.value[@"id"];
        FIRDatabaseQuery * currentDriver = [[self.ref child:@"publicUsers"]child:driverID];
        [currentDriver observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.driverName.text = snapshot.value[@"name"];
            NSString *str = snapshot.value[@"image"];
            NSURL * url = [NSURL URLWithString:str];
            NSData *data = [NSData dataWithContentsOfURL:url];
            self.driverImageView.image = [UIImage imageWithData:data];
        }];
    }];
    [self.submitBtn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}
-(void) submit: (UIButton *)sender{
    [[[self.ref child:@"posts"]child:self.postID]updateChildValues:@{@"rate":[NSString stringWithFormat:@"%f",self.rateValue.value]}];
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
