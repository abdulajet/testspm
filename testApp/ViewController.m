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
    
    NSString *token = @"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyMTEyMjAyNSwibmJmIjoxNTIxMTIyMDI1LCJleHAiOjE1MjExNTIwNTUsImp0aSI6MTUyMTEyMjA1NTA1NywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjUifQ.lAXI2T2obaVWKzEmMbcdehGViiEOePXMjj_m52UBTDolzvy1xCBB-DxGhr3MMTU8Zrf8QS3F50PaK-SP1xwaLeA-6pMx6m752M12AnxgSsKkgqdbywwxQ_zvPrIff1khoWR27OThdiKq_s_DGJjAZBi-hRHQkbOHJjh9d1XFxyNg_j4zL6F4E5Zv6_l_aWiy6kBLGMQTf3G9q2mt8O9lnnwvfzpidDGJhhh6vowfMzQRsfJW5cMtpUJSh9w-0aT6zkg_YFnYAqmmZm_vCuvU3R1dX2-RginOomkQqwnrzctBsatMK9PapRJfi8XxT_6aqxWGZL2PoDO4VNqzaB-afg";
    
    [self.client loginWithToken:token];
}

- (IBAction)addMemberPressed {
    
    [self.client addMemberToConversation:self.conversations[0] userId:self.memberField.text completionBlock:^(NSError * _Nullable error) {
        if (error) {
            // TODO: retry
        }
    }];
}

- (IBAction)createConversationPressed:(id)sender {
    __weak ViewController *weakSelf = self;
    
    [self.client newConversationWithConversationName:@"chenTest12" responseBlock:^(NSError * _Nullable error, NSString * _Nullable conversationId) {
        if (error) {
            // TODO: retry
        }
        
        if (conversationId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf conversationCreated:conversationId];
            });
        }
    }];
}

- (IBAction)sendMessegePressed:(id)sender {
    [self.client sendText:self.msgField.text conversationId:self.conversations[0] fromMemberId:self.members[0].memberId completionBlock:^(NSError * _Nullable error) {
       
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
    [self.client addMemberToConversation:convId userId:[self.client getUser].uuid completionBlock:^(NSError * _Nullable error) {
        if (error) {
            // TODO: retry
        }
    }];
}

#pragma mark - NXMConversationClientDelegate


- (void)memberJoined:(nonnull NXMMember *)member {
    [self.members addObject:member];
    
 //   if (member.user)
    
    self.outputField.text = [NSString stringWithFormat: @"%@\n\r member added id:%@ name:%@",self.outputField.text, member.memberId, member.name];
}


@end
