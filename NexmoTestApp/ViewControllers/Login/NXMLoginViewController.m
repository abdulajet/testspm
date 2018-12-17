//
//  NXMLoginVC.m
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMLoginViewController.h"
#import "ContactsViewController.h"
#import "UserSettingsViewController.h"
#import "MainTabViewController.h"

#import "NTAUserInfoProvider.h"
#import "NTALoginHandler.h"

#import "NTAAlertUtils.h"
#import "NTALogger.h"

@interface NXMLoginViewController () <NTALoginHandlerObserver>

@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *inprogressView;

@property(strong, nonatomic) NSArray<id <NSObject>> *loginSubscribers;
@end

@implementation NXMLoginViewController
- (IBAction)loadDefaultUserToTextFields:(UIButton *)sender {
    NTAUserInfo *randomUser = [NTAUserInfoProvider getRandomUser];
    self.username.text = randomUser.name;
    self.password.text = randomUser.password;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inprogressView.hidden = true;
    
    //Keyboard stuff
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    //logout
    self.loginSubscribers = [NTALoginHandler subscribeToNotificationsWithObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    //check if alreadyLoggedIn
    if([NTALoginHandler currentUser]) {
        [NTALoginHandler loginCurrentUserWithCompletion:^(NSError * _Nullable error, NTAUserInfo * _Nonnull userInfo) {
            [self didLogin];
        }];
    }
}

- (void)dealloc
{
    [NTALoginHandler unsubscribeToNotificationsWithObserver:self.loginSubscribers];
}

#pragma mark - Login
- (void)NTADidLogoutWithUserName:(NSString *)userName {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.username.text = @"";
        self.password.text = @"";
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)onLoginPressed:(UIButton *)sender {
    [self showInProgressView];
    
    __weak NXMLoginViewController *weakSelf = self;
    
    [NTALoginHandler loginWithUserName:self.username.text andPassword:self.password.text completion:^(NSError * _Nullable error, NTAUserInfo * _Nonnull userInfo) {
        
        [self hideInProgressView];
        
        if(error) {
            [self hideInProgressView];
            [NTAAlertUtils displayAlertForController:weakSelf WithTitle:@"Authentcation failed" andMessage:@"User name or password is incorrect"];
            return;
        }
        
        [self didLogin];
    }];
}


- (void)didLogin {
    [self showMainScreen];
}

#pragma mark - private



- (void)showMainScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ContactsViewController *contactsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ContactsList"];
    UserSettingsViewController *userSettingsVC = [storyboard instantiateViewControllerWithIdentifier:@"userSettings"];
    
    MainTabViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBar"];
    tabBarController.viewControllers = @[userSettingsVC, contactsViewController];
    
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

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

@end
