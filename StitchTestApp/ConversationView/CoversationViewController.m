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
//@property NSArray<NXMEvent *>* filteredEvents;

@property NSDictionary<NSString *,NSString *> * testUserIDs;

@property NSString *memberId;
@property NSString *userId;

@property BOOL isMediaEnabled;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NXMGetEventsRequest* getEventRequest = [NXMGetEventsRequest alloc];
    getEventRequest.conversationId = self.conversation.uuid;
    
    [self.stitch getEvents:getEventRequest onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.events addObject:events];
            [self.tableView reloadData];
        });
    } onError:^(NSError * _Nullable error) {
        NSLog(@"error get events");
    }];
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
//    self.filteredEvents = [self fiteredEventsForEvents:self.events];
    [self.tableView reloadData];
}

- (void)receivedMediaEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMediaEvent *media = userInfo[@"media"];
    if (![media.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    [self.events addObject:media];
//    self.filteredEvents = [self fiteredEventsForEvents:self.events];
    [self.tableView reloadData];
}

- (void)receivedTextEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMTextEvent *text = userInfo[@"text"];
    if (![text.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    [self.events addObject:text];
//    self.filteredEvents = [self fiteredEventsForEvents:self.events];
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
    if (self.isMediaEnabled) {
        self.isMediaEnabled = NO;
        [self.stitch disableMedia:self.conversation.uuid];
        return;
    }
    
    self.isMediaEnabled = YES;
    [self.stitch enableMedia:self.conversation.uuid memberId:self.memberId];
    
//    UIImage *image = [UIImage imageNamed:@"addMember"];
//    NSData *imageData = UIImagePNGRepresentation(image);
//
//    [self.stitch sendImage:imageData conversationId:self.conversation.uuid fromMemberId:self.memberId onSuccess:^(NSString * _Nullable value) {
//        NSLog(@"s");
//    } onError:^(NSError * _Nullable error) {
//        NSLog(@"error");
//    }];
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

    NXMGetEventsRequest* getEventRequest = [NXMGetEventsRequest alloc];
    getEventRequest.conversationId = conversation.uuid;
    
    [self.stitch getEvents:getEventRequest onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
        self.events = events;
        [self.tableView reloadData];
    } onError:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
//    return self.filteredEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXMEvent *event = self.events[indexPath.row];
    
    if (event.type == NXMEventTypeMember) {
        ConversationEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationEventCell"];
        [cell updateWithEvent:event];
        
        return cell;
    }
    
    if (event.type == NXMEventTypeMedia) {
        ConversationEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationEventCell"];
        [cell updateWithEvent:event];
        
        return cell;
    }
    if (event.type == NXMEventTypeText) {
        ConversationTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationTextCell"];
        if (cell == nil) {
            cell = [[ConversationTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationTextCell"];
            cell.backgroundColor = self.tableView.backgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        SenderType senderType = ([self.memberId isEqualToString:event.fromMemberId]) ? SenderTypeSelf : SenderTypeOther;
        [cell updateWithEvent:event senderType:senderType];
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXMEvent *event = self.events[indexPath.row];
    if (event.type == NXMEventTypeMember || event.type == NXMEventTypeMedia) {
        return 50.0f;
    }
    if (event.type == NXMEventTypeTextStatus) {
        return 0.1f;
    }
    
    NXMTextEvent *textEvent = (NXMTextEvent *)event;
    CGSize textSize = [textEvent.text boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                                   context:nil].size;
    CGSize nameSize = CGSizeZero;
    if (!([self.memberId isEqualToString:event.fromMemberId])) {
        nameSize = [event.fromMemberId boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f]}
                                                    context:nil].size;
    }
    
//    return size.height + 15.0f;
    return textSize.height + nameSize.height + 30.0f;
}

//- (NSArray<NXMEvent *> *)fiteredEventsForEvents:(NSMutableArray<NXMEvent *> *)events {
//    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
//        NXMEvent *event = (NXMEvent *)object;
////        return (event.type == NXMEventTypeMember || event.type == NXMEventTypeMedia || event.type == NXMEventTypeText);
//        return event.type == NXMEventTypeText;
//    }];
//    return [events filteredArrayUsingPredicate:predicate];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
