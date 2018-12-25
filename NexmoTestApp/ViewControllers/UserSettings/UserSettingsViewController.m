//
//  UserSettingsVCViewController.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "UserSettingsViewController.h"
#import "NTALoginHandler.h"
#import "NTAUserInfo.h"
#import "CommunicationsManager.h"
#import "NTALogger.h"
#import "NTAAlertUtils.h"


static NSString * const kNTAAvatarImageNameConnected = @"SettingsAvatarConnected";
static NSString * const kNTAAvatarImageNameNotConnected = @"SettingsAvatarNotConnected";
static NSString * const kNTAAvatarImageNameReconnecting = @"SettingsAvatarReconnecting";
static NSString * const kNTAAvatarImageNameConnectionOffline = @"SettingsAvatarConnectionOffline";


@interface UserSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *AvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *AvatarInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusReasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *csUserNamelabel;
@end

@implementation UserSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.statusReasonLabel.text = @"";
    [self setAvatarImageForStatus:CommunicationsManager.sharedInstance.connectionStatus];
    [self setLabelsWithUserInfo:[NTALoginHandler currentUser]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(connectionStatusChangedWithNSNotification:) name:kNTACommunicationsManagerNotificationNameConnectionStatus object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - Logout

- (IBAction)LogoutPressed:(UIButton *)sender {
    [NTALogger info:@"Logout pressed"];
    [NTALoginHandler logoutWithCompletion:^(NSError * _Nullable error) {
        if(error) {
            [NTAAlertUtils displayAlertForController:self WithTitle:@"Logout Failed" andMessage:@"An error occured while logging out of the system. please try again."];
        }
    }];
}


#pragma mark - CommunicationsManagerNotifications
- (void)connectionStatusChangedWithNSNotification:(NSNotification *)note {
    CommunicationsManagerConnectionStatus connectionStatus = (CommunicationsManagerConnectionStatus)([note.userInfo[kNTACommunicationsManagerNotificationKeyConnectionStatus] integerValue]);
    CommunicationsManagerConnectionStatusReason connectionStatusReason = (CommunicationsManagerConnectionStatusReason)([note.userInfo[kNTACommunicationsManagerNotificationKeyConnectionStatusReason] integerValue]);
    [self connectionStatusChanged:connectionStatus withReason:connectionStatusReason];
}

- (void)connectionStatusChanged:(CommunicationsManagerConnectionStatus)connectionStatus withReason:(CommunicationsManagerConnectionStatusReason)reason {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusReasonLabel.text = [CommunicationsManager CommunicationsManagerConnectionStatusReasonToString:reason];
        [self setAvatarImageForStatus:connectionStatus];
    });
}

#pragma mark - user ui
- (void)setAvatarImageForStatus:(CommunicationsManagerConnectionStatus)status {
    switch (status) {
        case CommunicationsManagerConnectionStatusNotConnected:
            [self.AvatarImage setImage:[UIImage imageNamed:kNTAAvatarImageNameNotConnected]];
            break;
        case CommunicationsManagerConnectionStatusReconnecting:
            [self.AvatarImage setImage:[UIImage imageNamed:kNTAAvatarImageNameReconnecting]];
            break;
        case CommunicationsManagerConnectionStatusConnected:
            [self.AvatarImage setImage:[UIImage imageNamed:kNTAAvatarImageNameConnected]];
            break;
        default:
            [self.AvatarImage setImage:[UIImage imageNamed:kNTAAvatarImageNameConnectionOffline]];
            break;
    }
}

- (void)setLabelsWithUserInfo:(NTAUserInfo *)userInfo {
    self.AvatarInitialsLabel.text = userInfo.initials;
    self.csUserNamelabel.text = userInfo.csUserName;
}

    
@end
