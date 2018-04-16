//
//  ViewController.m
//  testApp
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ViewController.h"

#import "StitchConversationClientCore.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.conversations = [NSMutableArray new];
    self.members = [NSMutableArray new];
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
        token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyMzg5MDUyOSwibmJmIjoxNTIzODkwNTI5LCJleHAiOjE1MjM5MjA1NTksImp0aSI6MTUyMzg5MDU1OTUzMiwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjEifQ.gRpBN1xS38OlGazO8pIkVk9CKH79yUTAndN74s8H-4-tPiSg5LvNp_1QzYLbzrFhBDG9e91wkZqDGfoGIWASeQBX9udbkXfkVTg1bXQRRePlCdUBX1pB8lm-Vc3PXTX7aBodS4_72mns5wv5ub2Y0MdHNmiPP9tGYCb8559lAI7jOOR3rf0MGCgBsd4In-BvXPqGF6yzdI5_p5VKqy-Dr1pLvaI573qtTLHDAcuH18IM_BLAjKoaXFa8PNJQMi3sFVB1h93CiP4Be6jr86HFpW5Ky-Q0eazdcgT81OpnnwoYbKrAlEXYTorjTeqasAk5onHItm6b4nrIlbiPmjaPww";
    }
    [self.client loginWithToken:token];
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
        NXMAddUserRequest *addUserRequest = [NXMAddUserRequest alloc];
        addUserRequest.userID = userId;
        addUserRequest.conversationID = self.conversations[0];
    [self.client addUserToConversation:addUserRequest completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
             weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r %@ error addUserToConversation member testUserID[%@] , conversion Id:%@ ",weakSelf.outputField.text,error.debugDescription,weakSelf.removeMemberField.text, weakSelf.conversations[0]];
            // TODO: retry
            });
        }
    }];
    }
}
- (IBAction)removeMemberPressed {
    __weak ViewController *weakSelf = self;
    NXMRemoveMemberRequest* removeMemberRequest = [NXMRemoveMemberRequest alloc];
    removeMemberRequest.conversationID = self.conversations[0];
    removeMemberRequest.memberID = self.removeMemberField.text;
    [self.client removeMemberFromConversation:removeMemberRequest completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r error remove member id:%@ , conversion Id:%@",weakSelf.outputField.text,error.debugDescription, weakSelf.conversations[0]];
            });
        }
    }];
}

- (IBAction)createConversationPressed:(id)sender {
    __weak ViewController *weakSelf = self;
    NXMCreateConversationRequest *createConversationRequest = [NXMCreateConversationRequest alloc];
    createConversationRequest.displayName = @"chenTest12";
    [self.client createConversation:createConversationRequest responseBlock:^(NSError * _Nullable error, NSString * _Nullable conversationId) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r %@ error conversation created id:%@",weakSelf.outputField.text,error.debugDescription, conversationId];
            });
        }
        
        if (conversationId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf conversationCreated:conversationId];
            });
        }
    }];
}

- (IBAction)getConversationPressed:(id)sender{
    __weak ViewController *weakSelf = self;
    
    [weakSelf.client getConversationDetails:weakSelf.conversations[0]
                     completionBlock: ^(NSError * _Nullable error, NXMConversationDetails * _Nullable data){
                         if (data != nil){
                             NSLog(@"getConversationPressed result %@",data);
                             dispatch_sync(dispatch_get_main_queue(), ^{
                                 weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r getConversationPressed result id:%@ ,name:%@",weakSelf.outputField.text, data.uuid, data.name];
                             });
                         }
                     }];
}


- (IBAction)getAllConversationPressed:(id)sender{
    __weak ViewController *weakSelf = self;
    NXMGetConversationsRequest* getConversationsRequest = [NXMGetConversationsRequest alloc];
    getConversationsRequest.pageSize = 100;
    [weakSelf.client getConversations:getConversationsRequest completionBlock:^(NSError * _Nullable error, NSArray<NXMConversationDetails *> * _Nullable data){
                         if (data != nil){
                             NSLog(@"getAllConversationPressed result %@",data);
                             dispatch_sync(dispatch_get_main_queue(), ^{
                                 for (NXMConversationDetails * detail in data){
                                     weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\rgetAllConversationPressed result \nuuid:%@ \nname:%@",weakSelf.outputField.text, detail.uuid, detail.name];
                                 }
                             });
                         }
                     }];
}
- (IBAction)sendMessegePressed:(id)sender {
    NXMSendTextEventRequest* sendTextEventRequest = [NXMSendTextEventRequest alloc];
    sendTextEventRequest.textToSend = self.msgField.text;
    sendTextEventRequest.conversationID = self.conversations[0];
    sendTextEventRequest.memberID = self.members[0].memberId;
    [self.client sendText:sendTextEventRequest completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {}];
}

- (IBAction)deleteMessegePressed:(id)sender {
    NXMDeleteEventRequest* deleteEventRequest = [NXMDeleteEventRequest alloc];
    deleteEventRequest.conversationID = self.conversations[0];
    deleteEventRequest.memberID = self.members[0].memberId;
    deleteEventRequest.eventID = self.deleteMsg.text;
    [self.client deleteText:deleteEventRequest  completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable conversationId) {}];
}

- (IBAction)typingOnPressed:(id)sender{
    [self.client textTypingOnEvent:self.conversations[0] memberId:self.members[0].memberId];
}
- (IBAction)typingOffPressed:(id)sender{
    [self.client textTypingOffEvent:self.conversations[0] memberId:self.members[0].memberId];
    
}
- (IBAction)textDeliveredPressed:(id)sender{
    [self.client deliverTextEvent:self.conversations[0] memberId:self.members[0].memberId eventId:self.deleteMsg.text];
}
- (IBAction)textSeenPressed:(id)sender{
    [self.client seenTextEvent:self.conversations[0] memberId:self.members[0].memberId eventId:self.deleteMsg.text];
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
    NXMAddUserRequest* addUserRequest = [NXMAddUserRequest alloc];
    addUserRequest.conversationID = convId;
    addUserRequest.userID = [self.client getUser].uuid;
    [self.client addUserToConversation:addUserRequest completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error)   {
            dispatch_sync(dispatch_get_main_queue(), ^{
               
            outputFieldW.text = [NSString stringWithFormat: @"%@\n\r %@ error addUserToConversation userId:%@ , conversion Id:%@",outputFieldW.text,error.debugDescription,[clientW getUser].uuid,convId];
                /* Do UI work here */
            });
        }
    }];
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
@end
