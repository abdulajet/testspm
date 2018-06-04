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

@interface CoversationViewController ()<UIGestureRecognizerDelegate, UITextViewDelegate>
@property StitchConversationClientCore *stitch;

@property (weak, nonatomic) IBOutlet UINavigationItem *title;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textinput;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIImageView *enableAudioImage;

@property NXMConversationDetails *conversation;
@property NSMutableArray<NXMEvent *> *events;
@property NSMutableDictionary *messageStatuses;
//@property NSArray<NXMEvent *>* filteredEvents;

@property NSDictionary<NSString *,NSString *> * testUserIDs;
@property NSMutableDictionary<NSString *,NSString *> * memberIdToName;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedTextStatusEvent:)
                                                 name:@"textStatusEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedImageEvent:)
                                                 name:@"imageEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedTypingEvent:)
                                                 name:@"typingEvent"
                                               object:nil];
    
    self.events = [NSMutableArray new];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.tableView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 1.0f;
    longPressGesture.delegate = self;
    [self.tableView addGestureRecognizer:longPressGesture];
    
    self.textinput.delegate = self;
    self.sendButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - events

- (void)receivedTypingEvent:(NSNotification *) notification {
}

- (void)receivedImageEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMImageEvent *imageEvent = userInfo[@"image"];
    if (![imageEvent.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    [self insertEvent:imageEvent];
}


- (void)receivedTextStatusEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMTextStatusEvent *textStatus = userInfo[@"textEvent"];
    if (![textStatus.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    [self insertTextStatusEvent:textStatus];
}

- (void)receivedMemberEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMemberEvent *member = userInfo[@"member"];
    if (![member.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    if ([member.user.name isEqualToString:self.stitch.getUser.name]) {
        self.memberId = member.memberId;
    }
    
    [self.memberIdToName setObject:member.user.name forKey:member.memberId];
    
    [self insertEvent:member];
//    [self reloadDataSource];
//    [self.tableView reloadData];
}

- (void)receivedMediaEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMediaEvent *media = userInfo[@"media"];
    if (![media.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
//    [self.events addObject:media];
    [self insertEvent:media];
//    [self reloadDataSource];
//    [self.tableView reloadData];
}

- (void)receivedTextEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMTextEvent *text = userInfo[@"text"];
    if (![text.conversationId isEqualToString:self.conversation.uuid]) {
        return;
    }
    
    [self insertEvent:text];
    
    [self.stitch markAsSeen:text.sequenceId conversationId:text.conversationId fromMemberWithId:self.memberId onSuccess:^{
        
    } onError:^(NSError * _Nullable error) {
        NSLog(@"error markAsSeen");
    }];
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
    self.sendButton.enabled = NO;
    self.textinput.editable = NO;
    [self.stitch sendText:self.textinput.text conversationId:self.conversation.uuid fromMemberId:self.memberId onSuccess:^(NSString * _Nullable value) {
        NSLog(@"msg sent");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textinput.editable = YES;
            self.textinput.text = @"";
            [self.textinput endEditing:YES];
        });
    } onError:^(NSError * _Nullable error) {
        NSLog(@"msg failed");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textinput.editable = YES;
        });
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
    [self startAudioAnimation];
     
    
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
    self.navigationItem.title = self.conversation.displayName;
    self.memberIdToName = [NSMutableDictionary new];
    
    [self.stitch getConversationDetails:self.conversation.uuid onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
        self.conversation = conversationDetails;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = self.conversation.displayName;
        });

        for (NXMMember *member in self.conversation.members) {
            if ([member.name isEqualToString:self.stitch.getUser.name]) {
                self.memberId = member.memberId;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
                    [appDelegate addConversationMember:member.conversationId memberId:member.memberId];
                });
            }
            
            [self.memberIdToName setObject:member.name forKey:member.memberId];
        }
        
        [self.stitch getEvents:self.conversation.uuid onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.events addObjectsFromArray:events];
                [self addNewEvents:events];
                [self.tableView reloadData];
                [self reloadDataSource];
            });
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error get events");
        }];
    } onError:^(NSError * _Nullable error) {
        NSLog(@"error get details");
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
    if (event.type == NXMEventTypeText || event.type == NXMEventTypeImage) {
        ConversationTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationTextCell"];
        if (cell == nil) {
            cell = [[ConversationTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationTextCell"];
            cell.backgroundColor = self.tableView.backgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        SenderType senderType = ([self.memberId isEqualToString:event.fromMemberId]) ? SenderTypeSelf : SenderTypeOther;
        MessageStatus messageStatus = MessageStatusNone;
        NSNumber *status = [self.messageStatuses objectForKey:@(event.sequenceId)];
        if (status) {
            messageStatus = [status integerValue];
        }
        [cell updateWithEvent:event
                   senderType:senderType
                   memberName:self.memberIdToName[event.fromMemberId]
                messageStatus:messageStatus];
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXMEvent *event = self.events[indexPath.row];
    if (event.type == NXMEventTypeMember || event.type == NXMEventTypeMedia) {
        return 50.0f;
    }
    
    if (event.type == NXMEventTypeText) {
        NXMTextEvent *textEvent = (NXMTextEvent *)event;
        CGSize boundSize = CGSizeMake(self.tableView.frame.size.width / 2.0f, CGFLOAT_MAX);
        CGSize textSize = [textEvent.text boundingRectWithSize:boundSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                                                       context:nil].size;
        CGSize nameSize = CGSizeZero;
        if (!([self.memberId isEqualToString:event.fromMemberId])) {
            nameSize = [event.fromMemberId boundingRectWithSize:boundSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f]}
                                                        context:nil].size;
        }
        
        //    return size.height + 15.0f;
        return textSize.height + nameSize.height + 40.0f;
    }
    
//    if (event.type == NXMEventTypeTextStatus) {
//        return 0.1f;
//    }
    return 0.1f;
}

#pragma mark - Gestures

- (void)handleTap:(UIGestureRecognizer *)recognizer {
   // [self.textinput endEditing:YES];
}

- (void)handleLongPress:(UIGestureRecognizer *)recognizer {
    CGPoint locationInView = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locationInView];
    NXMEvent *event = self.events[indexPath.row];
    
    if (![event.fromMemberId isEqualToString:self.memberId]) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"conversation" message:@"do you want to delete this msg?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.stitch deleteText:event.sequenceId conversationId:event.conversationId fromMemberId:event.fromMemberId onSuccess:^{
            
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error deleteText");
        }];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
    

}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    BOOL enabled = self.textinput.text.length > 0;
    self.sendButton.enabled = enabled;
}

#pragma mark - Helper Methods

- (void)addNewEvents:(NSMutableArray<NXMEvent *> *)events {
    for (NXMEvent *event in events) {
        if (event.type == NXMEventTypeTextStatus) {
            NXMTextStatusEvent *textStatusEvent = (NXMTextStatusEvent *)event;
            NSInteger sequenceId = textStatusEvent.eventId;
            NSNumber *currentStatus = [self.messageStatuses objectForKey:@(sequenceId)];
            if (!currentStatus || [currentStatus integerValue] < textStatusEvent.status) {
                [self.messageStatuses setObject:@(textStatusEvent.status) forKey:@(sequenceId)];
            }
        }
    }
    
    [self.events addObjectsFromArray:events];
}

- (void)insertTextStatusEvent:(NXMTextStatusEvent *)event {
    if ([self isEventExists:event]) {
        return;
    }
    
    NSInteger sequenceId = event.eventId;
    [self.messageStatuses setObject:@(event.status) forKey:@(sequenceId)];
//    NSIndexPath *indexPath = [self indexPathForSequenceId:sequenceId];
//    if (indexPath) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        if ([cell isKindOfClass:[ConversationEventTableViewCell class]]) {
//            if (event.status == NXMTextEventStatusEDeleted) {
//
//            }
//        }
//    }
    
    [self.events addObject:event];
    [self reloadDataSource];
}

- (NSIndexPath *)indexPathForSequenceId:(NSInteger)sequenceId {
    for (unsigned int index = 0; index < self.events.count; ++index) {
        NXMEvent *event = self.events[index];
        if (event.type == NXMEventTypeText && event.sequenceId == sequenceId) {
            return [NSIndexPath indexPathForRow:index inSection:0];
        }
    }
    return nil;
}

- (void)insertEvent:(NXMEvent *)event {
    if ([self isEventExists:event]) {
        return;
    }

    [self.events addObject:event];
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow: self.events.count - 1 inSection: 0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    [self scrollToBottom];
    
    [self reloadDataSource];
}
- (void)reloadDataSource {
    [self.tableView reloadData];
    [self scrollToBottom];
}

- (void)scrollToBottom {
    if (self.events.count == 0) {
        return;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow: self.events.count - 1 inSection: 0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)startAudioAnimation {
    [UIView animateWithDuration:1.0f
                     animations:^{
                         self.enableAudioImage.transform = CGAffineTransformScale(self.enableAudioImage.transform, 2.0f, 2.0f);
                     }
                     completion:^(BOOL finished) {
                         [self endAudioAnimation];
                     }];
}

- (void)endAudioAnimation {
    [UIView animateWithDuration:1.0f
                     animations:^{
                         self.enableAudioImage.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         if (self.isMediaEnabled) {
                             [self startAudioAnimation];
                         }
                     }];
}

- (BOOL)isEventExists:(NXMEvent *)event {
    for (NXMEvent *curr in self.events) {
        if (curr.sequenceId == event.sequenceId) {
            return YES;
        }
    }
    
    return NO;
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
