//
//  NXMLoginVC.m
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMLoginViewController.h"
#import "UserSettingsViewController.h"
#import "MainTabViewController.h"
#import "DialerViewController.h"
#import "ConversationsTableViewController.h"
#import "CommunicationsManager.h"

#import "NTALoginHandler.h"

#import "NTAAlertUtils.h"
#import "NTALogger.h"
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "TokenGenerator.h"

@interface NXMLoginViewController ()

@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *inprogressView;
@property (nonatomic) TokenGenerator* tokenGenerator;
@end

@implementation NXMLoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inprogressView.hidden = true;
    
    //Keyboard stuff
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    //notifications
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(NTADidLogoutWithNotification:) name:kNTALoginHandlerNotificationNameUserDidLogout object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    //check if alreadyLoggedIn
    if([NTALoginHandler currentUser]) {
        self.username.text = [NTALoginHandler currentUser];
        [self onLoginPressed:nil];
    }
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Login
- (void)NTADidLogoutWithNotification:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.username.text = @"";
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)onLoginPressed:(UIButton *)sender {
    [self showInProgressView];
    self.tokenGenerator = [[TokenGenerator alloc] initWithUsername:self.username.text andCallback:^(NSError * _Nullable error, NSString * _Nullable token) {
        [self hideInProgressView];

        [NSNotificationCenter.defaultCenter postNotificationName:kNTALoginHandlerNotificationNameUserDidLogin object:nil userInfo:@{@"username":self.username.text}];
            
        if(error) {
            [self hideInProgressView];
            [NTAAlertUtils displayAlertForController:self withTitle:@"Authentcation failed" andMessage:@"User name is incorrect"];
            return;
        }
        
        if (token) {
            [CommunicationsManager.sharedInstance loginWithUserToken:token];
        }
        
        [self didLogin];
    }];
    [self.tokenGenerator getToken:self];
    
}


- (void)didLogin {
    [self showMainScreen];
}

#pragma mark - private



- (void)showMainScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UserSettingsViewController *userSettingsVC = [storyboard instantiateViewControllerWithIdentifier:@"UserSettings"];
    
    DialerViewController *dialerVC = [storyboard instantiateViewControllerWithIdentifier:@"dialer"];

    UINavigationController *conversationsNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"conversationsNavigationController"];

    MainTabViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBar"];
    tabBarController.viewControllers = @[dialerVC,
                                         conversationsNavigationController,
                                         userSettingsVC];
    
    [self presentViewController:tabBarController animated:NO completion:nil];
}

- (void)showInProgressView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inprogressView.hidden = false;
        [self.activityIndicator startAnimating];
    });
}

- (void)hideInProgressView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        self.inprogressView.hidden = true;
    });
}

#pragma mark - UITextFieldDelegate

- (void)handleSingleTap:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

@end
