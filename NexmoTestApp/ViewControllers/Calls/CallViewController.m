//
//  InCallViewController.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/19/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "CallViewController.h"
#import "CallCreator.h"
#import "NTAUserInfo.h"
#import "NTALogger.h"
#import "NTAAlertUtils.h"

@interface CallViewController () <NXMCallDelegate>
@property (weak, nonatomic) IBOutlet UIView *InCallView;
@property (weak, nonatomic) IBOutlet UIImageView *InCallAvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *InCallAvatarInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *InCallUserNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *InCallMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *InCallSpeakerButton;
@property (weak, nonatomic) IBOutlet UIButton *InCallEarmuffButton;
@property (weak, nonatomic) IBOutlet UIButton *InCallHoldButton;
@property (weak, nonatomic) IBOutlet UIButton *InCallKeyPadButton;
@property (weak, nonatomic) IBOutlet UIButton *InCallEndCallButton;
@property (weak, nonatomic) IBOutlet UILabel *InCallStatusLabel;


@property (weak, nonatomic) IBOutlet UIView *IncomingCallView;
@property (weak, nonatomic) IBOutlet UIImageView *IncomingCallAvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *IncomingCallInitialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *IncomingCalluserNameLabel;


@property (nonatomic) NTAUserInfo *contactUserInfo;
@property (nonatomic) id<CallCreator> callCreator;
@property (nonatomic) NXMCall *call;
@property (nonatomic) BOOL isControllerInIncomingCallState;
@end

@implementation CallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateContactUI];
    [self updateInCallStatusLabelWithText:@"Connecting"];
    [self.callCreator callWithDelegate:self completion:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        if(error) {
            [self didFailCreatingCallWithError:error];
            return;
        }
        
        [self didCreateCall:(NXMCall *)call];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    if(self.isControllerInIncomingCallState) {
        [self activateIncomingCallView];
    } else {
        [self activateInCallView];
    }
}

#pragma mark - init
- (void)updateWithContactUserInfo:(NTAUserInfo *)contactUserInfo callCreator:(id<CallCreator>)callCreator andIsIncomingCall:(BOOL)isIncomingCall {
    self.contactUserInfo = contactUserInfo;
    self.callCreator = callCreator;
    self.isControllerInIncomingCallState = isIncomingCall;
}

- (void)updateContactUI {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateContactUI];
        });
        return;
    }
    
    self.IncomingCallInitialsLabel.text = self.contactUserInfo.initials;
    self.IncomingCalluserNameLabel.text = self.contactUserInfo.displayName;
    self.InCallAvatarInitialsLabel.text = self.contactUserInfo.initials;
    self.InCallUserNameLabel.text = self.contactUserInfo.displayName;
}

- (void)activateInCallView {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self activateInCallView];
        });
        return;
    }
    
    self.isControllerInIncomingCallState = NO;
    [self.InCallView setHidden:NO];
    [self.IncomingCallView setHidden:YES];
}

- (void)activateIncomingCallView {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self activateIncomingCallView];
        });
        return;
    }
    
    self.isControllerInIncomingCallState = YES;
    [self.IncomingCallView setHidden:NO];
    [self.InCallView setHidden:YES];
}

- (void)didFailCreatingCallWithError:(NSError *)error {
    [self updateInCallStatusLabelWithText:@"Error"];

    [NTAAlertUtils displayAlertForController:self WithTitle:@"Call Failed" andMessage:[NSString stringWithFormat:@"Call failed with error: %@", error] andActionBlock:^(UIAlertAction * _Nonnull action) {
            [self dismiss];
    }];
}

- (void)didCreateCall:(NXMCall *)call {
    self.call = call;
    [self updateInCallStatusLabelWithText:@"Dialing"];
    if(self.isControllerInIncomingCallState) {
        [self activateInCallView];
    }
}

- (void)updateInCallStatusLabelWithText:(NSString *)text {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateInCallStatusLabelWithText:text];
        });
        return;
    }
    
    self.InCallStatusLabel.text = text;
}

#pragma Mark IncomingCall

#pragma mark AnswerCall

- (IBAction)answerCallButtonPressed:(id)sender {
    
}

#pragma mark Decline Call

- (IBAction)declineCallButtonPressed:(UIButton *)sender {
    
    [self dismiss];
}

#pragma mark - InCall
- (IBAction)endCallButtonPressed:(UIButton *)sender {
    [self.call hangup:^(NSError * _Nullable error) {
        [NTALogger errorWithFormat:@"Failed hangup call with error: %@", error];
    }];
    [self dismiss];
}

- (void)didConnectCall {
    [self updateInCallStatusLabelWithText:@"Connected"];
}

- (void)didDisconnectCall {
    [self dismiss];
}


#pragma mark - NXMCallDelegate
- (void)statusChanged {
    switch (self.call.status) {
        case NXMCallStatusConnected:
            [self didConnectCall];
            break;
        case NXMCallStatusDisconnected:
            [self didDisconnectCall];
            break;
        default:
            break;
    }
}

- (void)holdChanged:(NXMCallParticipant *)participant isHold:(BOOL)isHold member:(NSString *)member {
    //TODO
}

- (void)mediaEvent:(NXMEvent *)mediaEvent {
    //TODO
}

- (void)memberEvent:(NXMMemberEvent *)memberEvent {
    //TODO
}

- (void)muteChanged:(NXMCallParticipant *)participant isMuted:(BOOL)isMuted member:(NSString *)member {
    //TODO
}

#pragma mark - Private
- (void)dismiss {
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismiss];
        });
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
