//
//  DialerViewController.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "DialerViewController.h"
#import "DailerTextField.h"
#import "PSTNCallCreator.h"
#import "CallViewController.h"

@interface DialerViewController ()
@property (weak, nonatomic) IBOutlet DailerTextField *textField;


//NSDate *momentTouchedDown;

@property NSTimer *digitLongPressTimer;

//BOOL isNumberContactKnown;

@end

@implementation DialerViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (IBAction)onButtonPressed:(id)sender {
    [self appendDigit:((UIButton *)sender).tag];
}

- (IBAction)onDeletePressed:(id)sender {
    [self.textField deleteDigit];
}

- (IBAction)onCallPressed:(id)sender {
    PSTNCallCreator *callCreator = [[PSTNCallCreator alloc] initWithNumber:self.textField.text];
    [self showInCallViewControllerWithCallCreator:callCreator];
}

- (void)appendDigit:(NSInteger)digitToAppend
{
    NSString *digitStrToAppend = [NSString stringWithFormat:@"%ld", (long)digitToAppend];
    [self.textField appendDigit:digitStrToAppend];
}

- (void)showInCallViewControllerWithCallCreator:(id<CallCreator>)callCreator {
    CallViewController *inCallVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Call"];
    [inCallVC updateWithNumber:self.textField.text callCreator:callCreator andIsIncomingCall:NO];
    [self presentViewController:inCallVC animated:YES completion:nil];
}

- (void)updateInfoLabels{
    
}
- (void)menuDidShow {
    
}
- (void)menuDidHide {
    
}

@end
