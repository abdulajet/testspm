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


static NSString * const kNTAAvatarImageNameConnected = @"SettingsAvatarConnected";
static NSString * const kNTAAvatarImageNameNotConnected = @"SettingsAvatarNotConnected";
static NSString * const kNTAAvatarImageNameReconnecting = @"SettingsAvatarReconnecting";
static NSString * const kNTAAvatarImageNameConnectionOffline = @"SettingsAvatarConnectionOffline";


@interface UserSettingsViewController () <CommunicationsManagerObserver>
@property (weak, nonatomic) IBOutlet UIImageView *AvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *AvatarInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusReasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *csUserNamelabel;


@property (nonatomic, nullable) NSArray<id <NSObject>> *nexmoClientWrapperSubscribers;
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
    self.nexmoClientWrapperSubscribers = [[CommunicationsManager sharedInstance] subscribeToNotificationsWithObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[CommunicationsManager sharedInstance] unsubscribeToNotificationsWithObserver:self.nexmoClientWrapperSubscribers];
    self.nexmoClientWrapperSubscribers = nil;
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
    [[CommunicationsManager sharedInstance] logout];
    [NTALoginHandler logout];
}


#pragma mark - ClientWrapperObserverDelegate
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
