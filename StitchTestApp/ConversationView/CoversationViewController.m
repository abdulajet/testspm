//
//  CoversationViewController.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "CoversationViewController.h"

#import "AppDelegate.h"

#import "ConversationTextTableViewCell.h"
#import "ConversationEventTableViewCell.h"
#import "NXMMemberEvent.h"

@interface CoversationViewController ()
@property StitchConversationClientCore *stitch;

@property (weak, nonatomic) IBOutlet UINavigationItem *title;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textinput;

@property NXMConversationDetails *conversation;
@property NSMutableArray<NXMEvent *>* events;

@property NSDictionary<NSString *,NSString *> * testUserIDs;

@property NSString *memberId;
@property NSString *userId;

@end

@implementation CoversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userId = @"USR-b0ffcfd1-332b-4074-9aeb-63c0c2fed205"; // testuser5;
    self.testUserIDs = @{@"testuser1":@"USR-727537eb-c68a-42f3-96a8-8a0947dd1da2",
                     @"testuser2":@"USR-1628dc75-fa09-4746-9e29-681430cb6419",
                     @"testuser3":@"USR-0e364e72-d343-42bd-9a12-024518a88896",
                     @"testuser4":@"USR-effc7845-333c-4779-aeaf-fdbb4167f93c",
                     @"testuser5":@"USR-b0ffcfd1-332b-4074-9aeb-63c0c2fed205",
                     @"testuser6":@"USR-de6954dc-9a54-4a65-8cf4-8628d312a611",
                     @"testuser7":@"USR-aecadd2c-8af1-44aa-8856-31c67d3f6e2b",
                     @"testuser8":@"USR-a7862767-e77a-4c0d-9bea-41754f1918c0"
                     };
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                    selector:@selector(receivedMemberEvent:)
                                                name:@"memberEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedMediaEvent:)
                                                 name:@"mediaEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedTextEvent:)
                                                 name:@"textEvent"
                                               object:nil];
    
    self.events = [NSMutableArray new];
}

- (void)receivedMemberEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMemberEvent *member = userInfo[@"member"];
    if (![member.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    if ([member.user.name isEqualToString:@"testuser5"]) {
        self.memberId = member.memberId;
    }
    
    [self.events addObject:member];
    [self.tableView reloadData];
}

- (void)receivedMediaEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMediaEvent *media = userInfo[@"media"];
    if (![media.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    [self.events addObject:media];
    [self.tableView reloadData];
}

- (void)receivedTextEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMTextEvent *text = userInfo[@"text"];
    if (![text.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    [self.events addObject:text];
    [self.tableView reloadData];
}

- (IBAction)addMemberPressed:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"add member" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"username";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *username =[[alertController textFields][0] text];
        NSLog(@"username %@", username);
        
        NSString * userId = self.testUserIDs[username];
        [self.stitch join:self.conversation.uuid withUserId:userId onSuccess:^(NSString * _Nullable value) {
            NSLog(@"success add username %@", username);
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error add username %@", username);
        }];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];;
}

- (IBAction)sendMsgPressed:(id)sender {
    [self.stitch sendText:self.textinput.text conversationId:self.conversation.uuid fromMemberId:self.memberId onSuccess:^(NSString * _Nullable value) {
        NSLog(@"msg sent");
    } onError:^(NSError * _Nullable error) {
        NSLog(@"msg failed");
    }];
}

- (IBAction)enableAudioPressed:(id)sender {
    [self.stitch enableMedia:self.conversation.uuid memberId:self.memberId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateWithConversation:(NXMConversationDetails*)conversation {
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    self.stitch = appDelegate.stitchConversation;
    
    self.conversation = conversation;
    self.navigationItem.title = self.conversation.name;
    
 //   [self.stitch join:conversation.uuid withUserId:[self.stitch getUser].uuid onSuccess:^(NSString * _Nullable value) {
//        [self.stitch getConversationEvents:conversation.uuid startOffset:0 endOffset:100 onSuccess:^(NSArray * _Nullable objects) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.events addObjectsFromArray:objects];
//                [self.tableView reloadData];
//            });
//        } onError:^(NSError * _Nullable error) {
//            NSLog(@"error get events");
//        }];
//    } onError:^(NSError * _Nullable error) {
//        NSLog(@"error add me");
//    }];

}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXMEvent *event = self.events[indexPath.row];
    
    if ([event.type isEqualToString:@"member"]) {
        ConversationEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationEventCell"];
        [cell updateWithEvent:event];
        
        return cell;
    }
    
    if ([event.type isEqualToString:@"media"]) {
        ConversationEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationEventCell"];
        [cell updateWithEvent:event];
        
        return cell;
    }
    
    ConversationTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationTextCell"];
    [cell updateWithEvent:event];
    
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
