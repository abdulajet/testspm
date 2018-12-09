//
//  NXMLoginVC.m
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMLoginVC.h"
#import "NTATokenProvider.h"
#import "NexmoClientWrapper.h"
#import "ContactsViewController.h"
#import "MainTabViewController.h"

@interface NXMLoginVC ()

@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *inprogressView;

@end

@implementation NXMLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inprogressView.hidden = true;
    
    //Keyboard stuff
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:@"loginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailedLogin:) name:@"loginFailure" object:nil];
}

- (IBAction)onLoginPressed:(UIButton *)sender {
    self.inprogressView.hidden = false;
    [self.activityIndicator startAnimating];
    
    __weak NXMLoginVC *weakSelf = self;
    [NTATokenProvider getTokenForUser:self.username.text
                             password:self.password.text
                           completion:^(NSError * _Nullable error, NSString *token) {
                               if (error) {
                                   // TODO:
                                   dispatch_async(dispatch_get_main_queue(), ^{

                                       UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Authentcation failed"
                                                                                                     message:@"username or password incorrect."
                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                       
                                       UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                                             handler:^(UIAlertAction * action) {}];
                                       
                                       [alert addAction:defaultAction];
                                       [self presentViewController:alert animated:YES completion:nil];
                                       
                                       self.inprogressView.hidden = false;
                                       [weakSelf.activityIndicator stopAnimating];
                                   });
                               }
                               
                               [NexmoClientWrapper.sharedInstance.client loginWithAuthToken:token];
                             }];
}


#pragma mark - NSNotificationCenter

- (void)didLogin:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMUser *user = userInfo[@"user"];

    // TODO: push
//    NSData *deviceToken = ((AppDelegate *)UIApplication.sharedApplication.delegate).deviceToken;
//    [[SCLStitchClients sharedWrapperClient].kommsClient enablePushNotificationsWithDeviceToken:deviceToken isPushKit:false isSandbox:true completion:^(NSError * _Nullable error) {
//        if(error) {
//            NSLog(@"device push enabling failed with error: %@", error);
//            return;
//        }
//        NSLog(@"device push enabling succeeded");
//    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inprogressView.hidden = true;
        [self.activityIndicator stopAnimating];

        [self showMainScreen];
    });
}

- (void)didFailedLogin:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSError *error = userInfo[@"error"]; // TODO: log
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.inprogressView.hidden = false;
        [self.activityIndicator stopAnimating];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Authentcation failed"
                                                                       message:@"username and password correct, nexmo token issue."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - private

- (void)showMainScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ContactsViewController *contactsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ContactsList"];
    
    MainTabViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"mainTabBar"];
    tabBarController.viewControllers = @[contactsViewController];
    
    [self presentViewController:tabBarController animated:NO completion:nil];
}


#pragma mark - UITextFieldDelegate

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

@end
