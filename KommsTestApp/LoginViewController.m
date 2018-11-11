//
//  LoginViewController.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <AVFoundation/AVAudioSession.h>
#import "LoginViewController.h"
#import "ConversationListViewContoller.h"
#import "ConversationManager.h"
#import "Tokens.h"
#import "KommsClients.h"
#import "KommsClientWrapper.h"
#import "StitchObjC.h"
#import "AppDelegate.h"

@interface LoginViewController() <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *userPicker;
@property NSDictionary<NSString *,NSString *> *usersNameToToken;
@property NSArray<NSString *> *usersNames;
@property NSString *selectedUser;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission: ^ (BOOL response)
         {
             NSLog(@"iOS 7+: Allow microphone use response: %d", response);
         }];
    }
    
    self.userPicker.delegate = self;
    self.userPicker.dataSource = self;
    
    self.usersNameToToken = @{@"testuser1":testUser1Token,
    @"testuser2":testUser2Token,
    @"testuser3":testUser3Token,
    @"testuser4":testUser4Token,
    @"testuser5":testUser5Token,
    @"testuser6":testUser6Token,
    @"testuser7":testUser7Token,
    @"testuser8":testUser8Token,
@"TheCustomer":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODk2Nzg2OSwibmJmIjoxNTI4OTY3ODY5LCJleHAiOjE1Mjg5OTc4OTksImp0aSI6MTUyODk2Nzg5OTQ4NCwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJUaGVDdXN0b21lciJ9.GA-SwbQoOeHv77wOBF-B6nflFc09oMIqCT_C3L7EntYXZcqc6wLFNIYivGHI8TQ0hue5tFKf06Ybx1Fhk9tBCB3Up9k_HVmxvCPSdx-voDPgiwU80X51ldHae8BBnX1awW5gQhrf3UfpBdBhv32XsX7fpKy5Z4lZTMQqHmozqemeNuJAYdH1tqFEuagtvsxGlhsQDqtyQR7PnW37KxDQ5EUvMJ2M0Qr1OwqelW8lDzmncL8kHnZp22VBaufzZqnM1NQt74rA8S5UIn4SW577hZyImcW408ostOUhJIfiDPBGTUt71BlGeoxygnHTUdH-WxZViVgu1yVRyKy728Z6CA",
@"TheTech":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODk2Nzk1NSwibmJmIjoxNTI4OTY3OTU1LCJleHAiOjE1Mjg5OTc5ODUsImp0aSI6MTUyODk2Nzk4NTYyOSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJUaGVUZWNoIn0.trQDVeZIok_DidN2rzUyrFRm_qPSj2YLOJxYL8pGsXHVdAk_oN119lU9cnKkMkQmLSfIG-YxfF5hNt-M15XEXH1yWmEQtI7WZr_0-owvAvMGu4US2kseiDhqCGydIS3rTnoM8g2D0Hg0CT_EfZg7ZBXj2oRzFmSrrcvfaJpeRhsgQdfRF7XqzqWIjJYf_G4KatkUO-uSSKGVFvI8z4t5_lctmQNMWaS7-0Ih6tDD_mUUoujrWvbnYdiIf2ymjErTi7z6TsqA4ZRrxviMAPT7nkDK8uKR9SGA-qyrxrbkUifHDue0TB1awnk-HgNtC59rB6nHWBb8HlT9piNZCTXK4g",
@"TheManager":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODk2Nzk5OCwibmJmIjoxNTI4OTY3OTk4LCJleHAiOjE1Mjg5OTgwMjgsImp0aSI6MTUyODk2ODAyODk2NywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJUaGVNYW5hZ2VyIn0.xrPVESnkhd438QqkEwoOOnfD776i3kehVAiGengajUj1g8qmR2tHEGekFrL_9YihSTYNLDT1vMEkumjJWfTM01BWgw8OO1nBdPR_0JCWC5_53RBEdrip3_IHjuhn7W0FqoqZMmZFT7nzRcCeS0Z6nyw_ERnE6XeXQop__4QwTX1detkoULWeFUrnWLeH5nfPy4BWdqgkUhlo3-e1xm3F5xMOrALk_2y0_fQYY00HYYUIz8nBODfZbrc35YvnQtXDhMi_oKk4srcjqMw7O_8Uu1-FeqjLuqrR0bgrCxYXFJaOvqLxX-1S3XBT_Wa4YuixHGyZk5lgVv4Lf-0pUJMQtg"
                    };
    self.usersNames = [self.usersNameToToken.allKeys sortedArrayUsingSelector:@selector(compare:)];
    [self.userPicker selectRow:0 inComponent:0 animated:NO];
    [self pickerView:self.userPicker didSelectRow:0 inComponent:0];
}

#pragma mark - UIPickerView
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.usersNames.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.usersNames[row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedUser = self.usersNames[row];
}

#pragma mark - login methods
- (IBAction)onLoginPressed:(UIButton *)sender {
    if(!self.selectedUser) {
        UIAlertAction *noUserAlertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        UIAlertController *noUserAlertController = [UIAlertController alertControllerWithTitle:nil message:@"No user selected.\nSelect a user to login" preferredStyle:UIAlertControllerStyleAlert];
        [noUserAlertController addAction:noUserAlertAction];
        [self presentViewController:noUserAlertController animated:true completion:nil];
        return;
    }
    
    //hack call to init conversationManager with the hack of the komms client - delete after finish tranformation to komms
    ConversationManager *conversationManager = ConversationManager.sharedInstance;
    
    [self subscribeLoginEvents];
    NSString *token = self.usersNameToToken[self.selectedUser];
    if (!token) {
        return;
    }
    [[KommsClients sharedWrapperClient].kommsClient loginWithAuthToken:token];
}

- (void)didSuccessfulLogin:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMUser *user = userInfo[@"user"];
    
    NSData *deviceToken = ((AppDelegate *)UIApplication.sharedApplication.delegate).deviceToken;
    [[KommsClients sharedWrapperClient].kommsClient enablePushNotificationsWithDeviceToken:deviceToken isPushKit:false isSandbox:true completion:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"device push enabling failed with error: %@", error);
            return;
        }
        NSLog(@"device push enabling succeeded");
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showConvertionListVC];
    });
}

- (void)didFailedLogin:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NSError *error = userInfo[@"error"];
    // TODO:
}

- (void)subscribeLoginEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccessfulLogin:) name:@"loginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailedLogin:) name:@"loginFailure" object:nil];
}

- (void)showConvertionListVC {
    ConversationListViewContoller *conversationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationNav"];
    
    [self presentViewController:conversationVC animated:YES completion:nil];
}
@end
