//
//  ViewController.m
//  testApp
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ViewController.h"

#import "StitchConversationClientCore.h"
#import <AVFoundation/AVAudioSession.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tokenText;
@property (weak, nonatomic) IBOutlet UITextField *msgField;
@property (weak, nonatomic) IBOutlet UITextField *deleteMsg;
@property (weak, nonatomic) IBOutlet UITextField *memberField;
@property (weak, nonatomic) IBOutlet UITextField *removeMemberField;
@property (weak, nonatomic) IBOutlet UITextView *outputField;

//@property NXMSocketClient *client;
@property StitchConversationClientCore *client;
@property NSMutableArray<NXMMember *> *members;
@property NSMutableArray *conversations;
@property NXMMember *mymember;


@end

@implementation ViewController

static NSString *const URL = @"https://ws.nexmo.com/";

- (NSString*)getRequestUUID{
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return uuid;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.conversations = [NSMutableArray new];
    self.members = [NSMutableArray new];
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission: ^ (BOOL response)
         {
             NSLog(@"iOS 7+: Allow microphone use response: %d", response);
         }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.outputField.text = @"";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginPressed {
    __weak ViewController *weakSelf = self;
    self.client = [[StitchConversationClientCore alloc] initWithConfig:[NXMConversationClientConfig new]];
    [self.client registerEventsWithDelegate:(id<NXMConversationClientDelegate>)weakSelf];

    NSString *token = self.tokenText.text;
    if ([token isEqualToString:(@"")]){
        token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyNzA2NDc1MSwibmJmIjoxNTI3MDY0NzUxLCJleHAiOjE1MjcwOTQ3ODEsImp0aSI6MTUyNzA2NDc4MTEyMiwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjQifQ.ArDyZ4qFsRteo1zn-Qu2dbg6fsNjik2B4EboyHDuv157ye-UODGKspGk3Mh36JQ6eRIVdvDSNK8VnBgV0XI-2QRhMTNCnYnrPuFz3JyCyFbydKR3VE2X2FtxIowUYGdmBktzRzTdBUo3k9Wo5FTyAMOwmg7jJVzqoyTABzu5HsoLlSetgfbGcQ6nOhH9_WyPzSjzPDNZDNI2pQj5jFjcm-MoD8_vQtDf7-sV6sR_pe32DdZqmBddkC1joeSw0MoBv-UJcGf1QRaF55TuJEwtz25SFL3CcsIBvzA3WecBbtgbrfTF35H6x88vpqgesOP4Zyxn-XjrF-yUeUFcPGbGXQ";
    }
//    [self.client loginWithToken:token];
    [self.client loginWithAuthToken:token];
}

- (IBAction)addMemberPressed {

    __weak ViewController *weakSelf = self;
    static NSString * testUserIDs[9] = {
    @"USR-727537eb-c68a-42f3-96a8-8a0947dd1da2",
    @"USR-1628dc75-fa09-4746-9e29-681430cb6419",
    @"USR-0e364e72-d343-42bd-9a12-024518a88896",
    @"USR-effc7845-333c-4779-aeaf-fdbb4167f93c",
    @"USR-b0ffcfd1-332b-4074-9aeb-63c0c2fed205",
    @"USR-de6954dc-9a54-4a65-8cf4-8628d312a611",
    @"USR-aecadd2c-8af1-44aa-8856-31c67d3f6e2b",
    @"USR-a7862767-e77a-4c0d-9bea-41754f1918c0"
    };

    if ([self.memberField.text isEqualToString:(@"")]){
         self.outputField.text = [NSString stringWithFormat: @"%@\n\r insert number between 0 - 7",self.outputField.text];
    }
    else{
        NSString *userId = @"";
        if (self.memberField.text.length > 2){
            userId = self.memberField.text;
        }
        else{
            userId = testUserIDs[self.memberField.text.intValue];
        }
        
        [self.client join:self.conversations[0] withUserId:userId onSuccess:^(NSString *value) {
            // TODO:
        } onError:^(NSError *error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r %@ error addUserToConversation member testUserID[%@] , conversion Id:%@ ",weakSelf.outputField.text,error.debugDescription,weakSelf.removeMemberField.text, weakSelf.conversations[0]];
                // TODO: retry
            });
        }];
    }
}
- (IBAction)removeMemberPressed {
//    __weak ViewController *weakSelf = self;
//    NXMRemoveMemberRequest* removeMemberRequest = [NXMRemoveMemberRequest alloc];
//    removeMemberRequest.conversationID = self.conversations[0];
//    removeMemberRequest.memberID = self.removeMemberField.text;
//    removeMemberRequest.requrstUUID = [self getRequestUUID];
//    [self.client removeMemberFromConversation:removeMemberRequest completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
//        if (error) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//            weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r error remove member id:%@ , conversion Id:%@",weakSelf.outputField.text,error.debugDescription, weakSelf.conversations[0]];
//            });
//        }
//    }];
}

- (IBAction)createConversationPressed:(id)sender {
    __weak ViewController *weakSelf = self;

    [self.client createWithName:@"chenTest122" onSuccess:^(NSString *value) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf conversationCreated:value];
        });
    } onError:^(NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r %@ error conversation created id:%@",weakSelf.outputField.text,error.debugDescription, @"ff"];
        });
    }];
}

- (IBAction)getConversationPressed:(id)sender{
//    __weak ViewController *weakSelf = self;
//
//    [weakSelf.client getConversationDetails:weakSelf.conversations[0]
//                     completionBlock: ^(NSError * _Nullable error, NXMConversationDetails * _Nullable data){
//                         if (data != nil){
//                             NSLog(@"getConversationPressed result %@",data);
//                             dispatch_sync(dispatch_get_main_queue(), ^{
//                                 weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r getConversationPressed result id:%@ ,name:%@",weakSelf.outputField.text, data.uuid, data.name];
//                             });
//                         }
//                     }];
}


- (IBAction)getAllConversationPressed:(id)sender{
//    __weak ViewController *weakSelf = self;
//    NXMGetConversationsRequest* getConversationsRequest = [NXMGetConversationsRequest alloc];
//    getConversationsRequest.pageSize = 100;
//    getConversationsRequest.requrstUUID = [self getRequestUUID];
//    [weakSelf.client getConversations:getConversationsRequest completionBlock:^(NSError * _Nullable error, NSArray<NXMConversationDetails *> * _Nullable data){
//                         if (data != nil){
//                             NSLog(@"getAllConversationPressed result %@",data);
//                             dispatch_sync(dispatch_get_main_queue(), ^{
//                                 for (NXMConversationDetails * detail in data){
//                                     weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\rgetAllConversationPressed result \nuuid:%@ \nname:%@",weakSelf.outputField.text, detail.uuid, detail.name];
//                                 }
//                             });
//                         }
//                     }];
}

- (IBAction)sendMessegePressed:(id)sender {
    [self.client sendText:self.msgField.text conversationId:self.conversations[0] fromMemberId:self.members[0].memberId onSuccess:^(NSString *value) {
        
    } onError:^(NSError *error) {
        // TODO:
    }];
}

- (IBAction)deleteMessegePressed:(id)sender {
//    NXMDeleteEventRequest* deleteEventRequest = [NXMDeleteEventRequest alloc];
//    deleteEventRequest.conversationID = self.conversations[0];
//    deleteEventRequest.memberID = self.members[0].memberId;
//    deleteEventRequest.eventID = self.deleteMsg.text;
//    deleteEventRequest.requrstUUID = [self getRequestUUID];
//    [self.client deleteText:deleteEventRequest  completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable conversationId) {}];
}

- (IBAction)typingOnPressed:(id)sender{
  //  [self.client textTypingOnEvent:self.conversations[0] memberId:self.members[0].memberId];
}
- (IBAction)typingOffPressed:(id)sender{
   // [self.client textTypingOffEvent:self.conversations[0] memberId:self.members[0].memberId];

}
- (IBAction)textDeliveredPressed:(id)sender{
  //  [self.client deliverTextEvent:self.conversations[0] memberId:self.members[0].memberId eventId:self.deleteMsg.text];
}
- (IBAction)textSeenPressed:(id)sender{
   // [self.client seenTextEvent:self.conversations[0] memberId:self.members[0].memberId eventId:self.deleteMsg.text];
}

- (void)connectedWithUser:(NXMUser *)user {

    self.outputField.text = [NSString stringWithFormat: @"%@\n\r connencted userId:%@",self.outputField.text, user.uuid];
}

- (void)conversationCreated:(NSString *)conversationId {
    [self.conversations addObject:conversationId];

    self.outputField.text = [NSString stringWithFormat: @"%@\n\r conversation created id:%@",self.outputField.text, conversationId];

    [self addMeToConversation:conversationId];
}

- (void)addMeToConversation:(NSString *)convId {
    UITextView* __weak outputFieldW = self.outputField;
    StitchConversationClientCore* __weak clientW = self.client;

    
    [self.client join:convId withUserId:[self.client getUser].uuid onSuccess:^(NSString *value) {
    } onError:^(NSError *error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            outputFieldW.text = [NSString stringWithFormat: @"%@\n\r %@ error addUserToConversation userId:%@ , conversion Id:%@",outputFieldW.text,error.debugDescription,[clientW getUser].uuid,convId];
            /* Do UI work here */
        });
    }];
}
- (IBAction)enableAudioPressed:(id)sender {
   // [self.client enableMedia:self.conversations[0]];
    [self.client enableMedia:self.conversations[0] memberId:self.members[0].memberId];
}

- (IBAction)disableAudioPressed:(id)sender {

}

#pragma mark - NXMConversationClientDelegate


- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent {
    //[self.members addObject:member];

    //   if (member.user)
    NXMMember *member = [NXMMember alloc];
    member.memberId = memberEvent.memberId;
    member.conversationId = memberEvent.conversationId;
    member.state = @"JOINED";
    [self.members addObject:member];
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r member added id:%@ name:%@",self.outputField.text, memberEvent.memberId, memberEvent.name];
}

- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent {
    //[self.members addObject:member];

    //   if (member.user)
    NXMMember *member = [NXMMember alloc];
    member.memberId = memberEvent.memberId;
    member.conversationId = memberEvent.conversationId;
    member.state = @"LEFT";
    [self.members addObject:member];

    self.outputField.text = [NSString stringWithFormat: @"%@\n\r member removed id:%@ name:%@",self.outputField.text, memberEvent.memberId, memberEvent.name];
}
- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent {
    //[self.members addObject:member];

    //   if (member.user)
    NXMMember *member = [NXMMember alloc];
    member.memberId = memberEvent.memberId;
    member.conversationId = memberEvent.conversationId;
    member.state = @"INVITED";
    [self.members addObject:member];

    self.outputField.text = [NSString stringWithFormat: @"%@\n\r member invited id:%@ name:%@",self.outputField.text, memberEvent.memberId, memberEvent.name];
}

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text received from id:%@ ,eventId:%@ ,msg:%@",self.outputField.text, textEvent.fromMemberId,textEvent.sequenceId, textEvent.text];

}
- (void)textDeleted:(nonnull NXMTextStatusEvent *)textEvent{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text deleted from id:%@ ,eventId:%@ ,msgDeletedId:%@",self.outputField.text, textEvent.fromMemberId,textEvent.sequenceId, textEvent.eventId];

}

- (void)textSeen:(nonnull NXMTextStatusEvent *)textEvent{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text seen from id:%@ ,eventId:%@ ,msgSeenId:%@",self.outputField.text, textEvent.fromMemberId,textEvent.sequenceId, textEvent.eventId];

}

- (void)textDelivered:(nonnull NXMTextStatusEvent *)textEvent{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text delivered from id:%@ ,eventId:%@ ,msgDeliveredId:%@",self.outputField.text, textEvent.fromMemberId,textEvent.sequenceId, textEvent.eventId];

}

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textEvent{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text typing on from id:%@ ,eventId:%@ ",self.outputField.text, textEvent.fromMemberId,textEvent.sequenceId];

}

- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textEvent{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text typing off from id:%@ ,eventId:%@ ",self.outputField.text, textEvent.fromMemberId,textEvent.sequenceId];

}


- (void)messageReceived:(nonnull NXMTextEvent *)message{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r message received from id:%@ msg:%@",self.outputField.text, message.fromMemberId, message.text];

}
- (void)messageSent:(nonnull NXMTextEvent *)message{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text received from id:%@ msg:%@",self.outputField.text, message.fromMemberId, message  .text];

}

- (void)localMediaChanged:(nonnull NXMMediaEvent *)mediaEvent {
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r media event:%@ msg:%@",self.outputField.text, mediaEvent.isMediaEnabled];
}

@end

