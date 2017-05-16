//
//  ScheduleViewController.m
//  Carpool
//
//  Created by Wenjun Weng on 4/29/17.
//  Copyright © 2017 rjt. All rights reserved.
//

#import "ScheduleViewController.h"
#import "PostViewController.h"

@interface ScheduleViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPicker;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;

@end

NSString *scheduleTime;
@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.dataPicker setHidden:YES];
    
}
- (IBAction)showDatePicker:(id)sender {
    [self.dataPicker setHidden:NO];
}

- (IBAction)dateValue:(UIDatePicker *)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, YYYY  HH:mm a"];
    scheduleTime = [formatter stringFromDate:sender.date];
    self.dateTextField.text = [formatter stringFromDate: sender.date];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PostViewController *pc = [segue destinationViewController];
    [pc setScheduleTime: scheduleTime];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

*/

@end
