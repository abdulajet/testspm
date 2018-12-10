//
//  SCLIncomingCallViewController.m
//  StitchClientTestApp
//
//  Created by Assaf Passal on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCLIncomingCallViewController.h"

#import "SCLConversationViewController.h"
#import "SCLConversationTextTableViewCell.h"
#import "SCLConversationEventTableViewCell.h"
#import "SCLConversationManager.h"
#import "SCLOngoingCallsViewController.h"
#import "SCLStitchClients.h"
#import "SCLStitchClientWrapper.h"

@interface SCLIncomingCallViewController ()< UITextViewDelegate, NXMConversationDelegate, NXMConversationEventsControllerDelegate, NXMCallDelegate>
@property SCLConversationManager *conversationManager;
@property SCLStitchClientWrapper *kommsWrapper;

@property NXMCall *call;

@property NSDictionary<NSString *,NSString *> * testUserIDs;
@property NSDictionary<NSString *,NSString *> * testUserNames;

@end

@implementation SCLIncomingCallViewController

- (void) updateWithCall:(NXMCall *)call{
    self.call = call;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.testUserIDs = @{@"testuser1":@"USR-727537eb-c68a-42f3-96a8-8a0947dd1da2",
                         @"testuser2":@"USR-1628dc75-fa09-4746-9e29-681430cb6419",
                         @"testuser3":@"USR-0e364e72-d343-42bd-9a12-024518a88896",
                         @"testuser4":@"USR-effc7845-333c-4779-aeaf-fdbb4167f93c",
                         @"testuser5":@"USR-b0ffcfd1-332b-4074-9aeb-63c0c2fed205",
                         @"testuser6":@"USR-de6954dc-9a54-4a65-8cf4-8628d312a611",
                         @"testuser7":@"USR-aecadd2c-8af1-44aa-8856-31c67d3f6e2b",
                         @"testuser8":@"USR-a7862767-e77a-4c0d-9bea-41754f1918c0",
                         @"TheCustomer":@"USR-f791c83e-0b9e-4671-88dd-9a64344ff2b3",
                         @"TheTech":@"USR-65aa7c31-f5ea-46fb-9a94-c712e5787f6e",
                         @"TheManager":@"USR-c0093b90-d91b-4932-b41d-4b043a5c95cb"
                         };
    
    self.testUserNames = @{@"USR-727537eb-c68a-42f3-96a8-8a0947dd1da2":@"testuser1",
                           @"USR-1628dc75-fa09-4746-9e29-681430cb6419":@"testuser2",
                           @"USR-0e364e72-d343-42bd-9a12-024518a88896":@"testuser3",
                           @"USR-effc7845-333c-4779-aeaf-fdbb4167f93c":@"testuser4",
                           @"USR-b0ffcfd1-332b-4074-9aeb-63c0c2fed205":@"testuser5",
                           @"USR-de6954dc-9a54-4a65-8cf4-8628d312a611":@"testuser6",
                           @"USR-aecadd2c-8af1-44aa-8856-31c67d3f6e2b":@"testuser7",
                           @"USR-a7862767-e77a-4c0d-9bea-41754f1918c0":@"testuser8",
                           @"USR-f791c83e-0b9e-4671-88dd-9a64344ff2b3":@"TheCustomer",
                           @"USR-65aa7c31-f5ea-46fb-9a94-c712e5787f6e":@"TheTech",
                           @"USR-c0093b90-d91b-4932-b41d-4b043a5c95cb":@"TheManager"
                           };
    
    self.conversationManager = self.conversationManager?: SCLConversationManager.sharedInstance;
    self.kommsWrapper = self.kommsWrapper ?: SCLStitchClients.sharedWrapperClient;
 
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
}
- (IBAction)answerPressed:(id)sender {
    [self.call answer:self completionHandler:^(NSError * _Nullable error) {
        
    }];
}
- (IBAction)rejectPressed:(id)sender {
    [self.call hangup:^(NSError * _Nullable error) {
        
    }];
}

//@implment CallDelegate
- (void)statusChanged{
    
}
- (void)holdChanged:(NXMCallParticipant *)participant isHold:(BOOL)isHold member:(NSString *)member{
    
}
- (void)muteChanged:(NXMCallParticipant *)participant isMuted:(BOOL)isMuted member:(NSString *)member{
    
}
- (void)mediaEvent:(NXMEvent *)mediaEvent{
    
}
- (void)memberEvent:(NXMMemberEvent *)memberEvent{
    
}

@end
