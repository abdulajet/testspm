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

#import "AppDelegate.h"

@interface LoginViewController()
@property (weak, nonatomic) IBOutlet UITextField *autoTokenField;
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

}
- (IBAction)onLoginPressed:(UIButton *)sender {
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);

    StitchConversationClientCore *stitch = [StitchConversationClientCore new];
    [appDelegate setStitch:stitch];

    NSString *token = self.autoTokenField.text;

    if ([token length] == 0) {
        token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODExNTYzOCwibmJmIjoxNTI4MTE1NjM4LCJleHAiOjE1MjgxNDU2NjgsImp0aSI6MTUyODExNTY2ODg2MiwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjYifQ.PXkHptCWOLsjG3If-70ybrtNUZExkuSqWoUA3TzbtxhtvKudHG41iIPpV064eJ1q_mG5vnqWrVHaYob_PfAKsZonFhq7vI-aG6kJ5AZHK_hw80BT6-M0XwGlxIpGNrD5u1Xtopp-7CvqXesYMAXep0TgsaYphkOjs4V2VExlTaD5M0HUfOmBAW1UfDleJwkSq1KaA63ZHCpzsngAiE5jv1tyMBBIerzvGo7xNI6BhFqiVec16_GqPN7mskWlKjpp1deueCrZaP3qavGQTewRhsO_iX13JfyfayzHzCAokyuFKBVqu_xLO-VnDOAqaYn9xn2zPOWpkNvExmSCARGMSw";
    }

    [stitch loginWithAuthToken:token onSuccess:^(NSObject * _Nullable object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showConvertionListVC];
        });
    } onError:^(NSError * _Nullable error) {
        // TODO:
    }];
}

- (void)showConvertionListVC {
    ConversationListViewContoller *conversationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationNav"];
    
    [self presentViewController:conversationVC animated:YES completion:nil];
}


@end
