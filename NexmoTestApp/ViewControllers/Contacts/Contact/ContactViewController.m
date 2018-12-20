//
//  ContactViewController.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/18/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ContactViewController.h"

#import "NTAUserInfo.h"
#import "InAppcallCreator.h"
#import "CallViewController.h"

@interface ContactViewController ()
@property (weak, nonatomic) IBOutlet UILabel *avatarInitialisLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (nonatomic) NTAUserInfo *contactUserInfo;
@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - init
- (void)updateWithContactUserInfo:(NTAUserInfo *)contactUserInfo {
    self.contactUserInfo = contactUserInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.avatarInitialisLabel.text = contactUserInfo.initials;
        self.userNameLabel.text = contactUserInfo.displayName;
    });
}

#pragma mark - calls

- (IBAction)callInAppButtonPressed:(UIButton *)sender {
    //create an NTA Call Object and initialize with inApp parameters it so that when we move to the next screen the next screen just calls start.
    InAppCallCreator *callCreator = [[InAppCallCreator alloc] initWithUsers:@[self.contactUserInfo]];
    [self showInCallViewControllerWithCallCreator:callCreator];
}


- (IBAction)callServerButtonPressed:(UIButton *)sender {
    
}

- (void)showInCallViewControllerWithCallCreator:(id<CallCreator>)callCreator {
    CallViewController *inCallVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Call"];
    [inCallVC updateWithContactUserInfo:self.contactUserInfo callCreator:callCreator andIsIncomingCall:NO];
    [self presentViewController:inCallVC animated:YES completion:nil];
}

#pragma mark - messages

- (IBAction)messageButtonPrerssed:(UIButton *)sender {
    
}
@end
