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
        token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyNzU4MjA0OCwibmJmIjoxNTI3NTgyMDQ4LCJleHAiOjE1Mjc2MTIwNzgsImp0aSI6MTUyNzU4MjA3ODk4MiwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjUifQ.gUWVUIr2CF7AVcnnT9nB8l6BCfn-qXdKA5ZANvpXcgcpiKpYOBZj55FjYnUgqKLGpJ6zIamG8HcnXWJLsJ8-hLP4wUG3JPD2u3ziUo195gt6YXtAWZRmPSTcOV9n3-h1JUUpTxG95m3xIMsu7yJRNG7khdTI8F1hUPUYr-Okr6zIaq6EXdCCngr2iViXvFKmr9FAtfFpgLIPHj-acLJ_3QugrMTkptRhrJOADzeZP4xW8FhCX1vdQVNSajZsVR52bwJ5R16TthUH0ueyveeBs1IIiyATN1Oh8C5qa0bTcgYJBKSce7AoH-6P4m537qJMb-_ksVn7ApnDRdeMZ2LSDQ";
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
