//
//  ViewController.m
//  testApp
//
//  Created by Chen Lev on 2/15/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ViewController.h"

#import "NexmoConversationObjC.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tokenText;
@property (weak, nonatomic) IBOutlet UITextField *msgField;
@property (weak, nonatomic) IBOutlet UITextField *memberField;
@property (weak, nonatomic) IBOutlet UITextField *removeMemberField;
@property (weak, nonatomic) IBOutlet UITextView *outputField;

//@property NXMSocketClient *client;
@property NXMConversationClient *client;
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
    self.client = [[NXMConversationClient alloc] initWithConfig:[NXMConversationClientConfig new]];
    [self.client registerEventsWithDelegate:self];
    
    NSString *token = self.tokenText.text;
    if ([token isEqualToString:(@"")]){
        token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyMTk2NDUxMSwibmJmIjoxNTIxOTY0NTExLCJleHAiOjE1MjE5OTQ1NDEsImp0aSI6MTUyMTk2NDU0MTgwNCwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjEifQ.nZ6TvqrOXw7CBHDo6GXYfaHG2WH0PIvXvIUqSxezxqo5nQlzVCv9np63OFcx5yZ-T_HT_vtTCvujsT5_OXbMDDfevx8a4KGqSk6JQpO0n0bdc-gksID8-g54m2PzoglhO4PG3Ib4NZyAFkLxM6FA8rJiH2MHkjCNr1jF8mQhAp6rVq71n4dAxWlVLffGVgmHGOZYP2XJnZJwULWaZWUqUFzQTtmTmkTKX8IYGVqd2fMesFrmMl4szt6zOn1qf9F03k5VAoCLURO-JnzwBsWZx7CGjfJcoO8nKgACxgMHK7nb4dVOFfXx--pfk6PWG1BUBWtX08dasQQt40XtFdN0EQ";
    }
    [self.client loginWithToken:token];
}

- (IBAction)addMemberPressed {
    
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
    [self.client addUserToConversation:self.conversations[0] userId:userId completionBlock:^(NSError * _Nullable error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
             self.outputField.text = [NSString stringWithFormat: @"%@\n\r %@ error addUserToConversation member testUserID[%@] , conversion Id:%@ ",self.outputField.text,error.debugDescription,self.removeMemberField.text, self.conversations[0]];
            // TODO: retry
            });
        }
    }];
    }
}
- (IBAction)removeMemberPressed {
    __weak ViewController *weakSelf = self;
    [self.client removeMemberFromConversation:self.conversations[0] memberId:self.removeMemberField.text completionBlock:^(NSError * _Nullable error) {
        if (error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.outputField.text = [NSString stringWithFormat: @"%@\n\r error remove member id:%@ , conversion Id:%@",weakSelf.outputField.text,error.debugDescription, weakSelf.conversations[0]];
            });
        }
    }];
}

- (IBAction)createConversationPressed:(id)sender {
    __weak ViewController *weakSelf = self;
    
    [self.client newConversationWithConversationName:@"chenTest12" responseBlock:^(NSError * _Nullable error, NSString * _Nullable conversationId) {
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

- (IBAction)sendMessegePressed:(id)sender {
    [self.client sendText:self.msgField.text conversationId:self.conversations[0] fromMemberId:self.members[0].memberId completionBlock:^(NSError * _Nullable error, NSString * _Nullable conversationId) {
       
    }];
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
    NXMConversationClient* __weak clientW = self.client;
    [self.client addUserToConversation:convId userId:[self.client getUser].uuid completionBlock:^(NSError * _Nullable error) {
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
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text received from id:%@ msg:%@",self.outputField.text, textEvent.fromMemberId, textEvent.text];

}

- (void)messageReceived:(nonnull NXMTextEvent *)message{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r message received from id:%@ msg:%@",self.outputField.text, message.fromMemberId, message.text];

}
- (void)messageSent:(nonnull NXMTextEvent *)message{
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r text received from id:%@ msg:%@",self.outputField.text, message.fromMemberId, message  .text];

}
@end
