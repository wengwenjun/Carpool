//
//  passenegerViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 5/1/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "passenegerViewController.h"
#import "RequestViewController.h"

@interface passenegerViewController ()
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic) NSString *scheduleTime;

@end

@implementation passenegerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.datePicker setHidden:YES];
}

- (IBAction)showDate:(id)sender {
    [self.datePicker setHidden:NO];
}

- (IBAction)valueChanges:(UIDatePicker *)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, YYYY  HH:mm a"];
    self.scheduleTime = [formatter stringFromDate:sender.date];
    self.timeTextField.text= [formatter stringFromDate: sender.date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    RequestViewController *rc = [segue destinationViewController];
    [rc setScheduleTime:self.scheduleTime];
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
