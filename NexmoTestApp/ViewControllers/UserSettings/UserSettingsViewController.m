//
//  UserSettingsVCViewController.m
//  NexmoTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "UserSettingsViewController.h"

#import <MessageUI/MessageUI.h>

#import "NTALoginHandler.h"
#import "NTAUserInfo.h"
#import "CommunicationsManager.h"
#import "NTALogger.h"
#import "NTAAlertUtils.h"

static NSString * const kNTAAvatarImageNameConnected = @"SettingsAvatarConnected";
static NSString * const kNTAAvatarImageNameNotConnected = @"SettingsAvatarNotConnected";
static NSString * const kNTAAvatarImageNameReconnecting = @"SettingsAvatarReconnecting";
static NSString * const kNTAAvatarImageNameConnectionOffline = @"SettingsAvatarConnectionOffline";


@interface UserSettingsViewController () <MFMailComposeViewControllerDelegate>
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
            [NTAAlertUtils displayAlertForController:self withTitle:@"Logout Failed" andMessage:@"An error occured while logging out of the system. please try again."];
        }
    }];
}

#pragma mark - Logs

- (IBAction)sendLogsPressed:(UIButton *)sender {
    
//    if(![MFMailComposeViewController canSendMail]) {
//        [NTAAlertUtils displayAlertForController:self withTitle:@"Send Logs" andMessage:@"Can't send mail. Please make sure sending mails is enabled for this device" andDismissAfterSeconds:1];
//        return;
//    }
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currDateString = [dateFormatter stringFromDate:currDate];
    NSString *logName = [NSString stringWithFormat:@"NexmoTestApp iOS Logs [objective-c] %@", currDateString];
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:logName];
    [mailController setToRecipients:@[@"ayelet.levy@vonage.com"]];
    
    NSString *messageBody = [self randomSentence];
    NSArray* files = [NTALogger getLogs];
    [mailController setMessageBody:messageBody isHTML:NO];
    
    NSString *name = [files count] > 0 ? files[0] : @"noLog";
    NSMutableData *mergedData = [NSMutableData data];
    [files enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *logData = [[NSFileManager defaultManager] contentsAtPath:obj];
        if ([logData length] > 0) {
            [mergedData appendData:logData];
        }
        
        [mailController addAttachmentData:logData
                                 mimeType:@"text/plain"
                                 fileName:[obj stringByAppendingString:@".log"]];
    }];
    
    [mailController addAttachmentData:mergedData
                             mimeType:@"text/plain"
                             fileName:[name stringByAppendingString:@"merged.log"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:mailController animated:YES completion:nil];
    });
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:
    (MFMailComposeResult)result error:(nullable NSError *)error {
    __weak UserSettingsViewController *weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        switch (result) {
            case MFMailComposeResultFailed:
                [NTAAlertUtils displayAlertForController:weakSelf withTitle:@"Send Mail" andMessage:@"failed sending mail" andDismissAfterSeconds:1];
                break;
            default:
                break;
        }
    }];
}

- (NSString *)randomSentence {
    NSString *sentencesPath = [NSBundle.mainBundle pathForResource:@"Sentences" ofType:@"plist"];
    NSArray *sentences = [[NSDictionary alloc] initWithContentsOfFile:sentencesPath][@"sentences"];
    NSUInteger rand = arc4random_uniform((uint)sentences.count);
    return sentences[rand];
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
