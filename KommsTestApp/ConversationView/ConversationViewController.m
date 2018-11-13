//
//  CoversationViewController.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#import "ConversationViewController.h"

#import "ConversationTextTableViewCell.h"
#import "ConversationEventTableViewCell.h"
#import "NXMMemberEvent.h"
#import "ConversationManager.h"
#import "OngoingCallsViewController.h"
#import "NXMConversation.h"
#import "KommsClients.h"
#import "KommsClientWrapper.h"
#import "NXMStitchClient.h"

const CGFloat ONGOING_CALLS_OPEN_HEIGHT = 300;
const CGFloat ONGOING_CALLS_BUTTON_VISIBLE_HEIGHT = 44;
const NSUInteger AMOUNT_OF_EVENTS_TO_LOAD_MORE = 20;

@interface ConversationViewController ()<UIGestureRecognizerDelegate, UITextViewDelegate, NXMConversationEventsControllerDelegate, NXMCallDelegate>
@property ConversationManager *conversationManager;
@property KommsClientWrapper *kommsWrapper;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewContraint;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textinput;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIImageView *enableAudioImage;
@property (weak, nonatomic) IBOutlet UILabel *typingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadMoreActivityIndicator;

@property NXMCall *call;
@property NXMConversation *conversation;
@property NXMConversationDetails *conversationDetails;
@property NXMConversationEventsController *eventsController;
@property NXMConversationMembersController *membersController;

@property NSDictionary<NSString *,NSString *> * testUserIDs;
@property NSDictionary<NSString *,NSString *> * testUserNames;

@property NSString *memberId;
@property NSString *userId;

@property BOOL isAudioEnabled;
@property BOOL isLoadMoreRequested;

//ongoign calls
@property (weak, nonatomic) IBOutlet UIView *onGoingCallsView;
@property (weak, nonatomic) IBOutlet UIButton *onGoingCallsTrayButton;
@property (weak, nonatomic) IBOutlet UIView *onGoingCallsContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onGoingCallsContainerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onGoingCallsTrayButtonHeightConstraint;
@property BOOL isOnGoingCallsViewTrayOpen;


@end

@implementation ConversationViewController



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
    
    self.conversationManager = self.conversationManager?: ConversationManager.sharedInstance;
    self.kommsWrapper = self.kommsWrapper ?: KommsClients.sharedWrapperClient;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedMediaEvent:)
                                                 name:@"mediaEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedTextEvent:)
                                                 name:@"textEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedTypingEvent:)
                                                 name:@"typingEvent"
                                               object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
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
    
    [self disableOngoingCallsTray];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self subscribeConnectionEvents];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.typingLabel.hidden = YES;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - keyboard

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    self.textViewContraint.constant = keyboardSize.height - 40;
    [self.view layoutIfNeeded];
    
}

- (void)keyboardWillHide:(NSNotification*)notification {
    self.textViewContraint.constant = 0;
    [self.view layoutIfNeeded];
}

- (void)updateSendButtonIfNeeded {
    self.sendButton.enabled = (self.kommsWrapper.kommsClient.isConnected && self.textinput.text.length > 0) ? YES : NO;
}
#pragma mark - login (reconnect)
- (void)subscribeConnectionEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccessfulLogin:) name:@"loginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusChanged:) name:@"connectionStatusChanged" object:nil];
}

- (void)didSuccessfulLogin:(NSNotification *)notification {
    [self updateWithConversation:self.conversation];
}

- (void)connectionStatusChanged:(NSNotification *)notification {
    [self updateSendButtonIfNeeded];
}

#pragma mark - events ******** events still supported by core

- (void)receivedTypingEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMTextTypingEvent *typing = userInfo[@"typingEvent"];
    
    if (![typing.conversationId isEqualToString:self.conversation.conversationId]) {
        return;
    }
    
    if ([typing.fromMemberId isEqualToString:self.membersController.myMember.memberId]) {
        return;
    }
    
    if (typing.status == NXMTextTypingEventStatusOff) {
        self.typingLabel.hidden = YES;
        return;
    }
    
    NSString* memberName = [self.membersController memberForMemberId:typing.fromMemberId].name;
    if (!memberName) {
        return;
    }
    
    self.typingLabel.text = [NSString stringWithFormat:@"%@ is typing...", memberName];
    self.typingLabel.hidden = NO;
}

- (void)receivedMediaEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMediaEvent *media = userInfo[@"media"];
    if (![media.conversationId isEqualToString:self.conversation.conversationId]) {
        return;
    }
    
    if([self.conversationManager.ongoingCalls countForConversation:media.conversationId] > 0) {
        [self enableOngoingCallsTray];
    } else {
        [self disableOngoingCallsTray];
    }
}

- (void)receivedTextEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMTextEvent *text = userInfo[@"text"];
    if (![text.conversationId isEqualToString:self.conversation.conversationId]) {
        return;
    }

    if (self.membersController.myMember.memberId) {
        [self.conversationManager.stitchConversationClient markAsSeen:text.sequenceId conversationId:text.conversationId fromMemberWithId:self.membersController.myMember.memberId onSuccess:^{
        
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error markAsSeen");
        }];
    }
}

#pragma mark - User Press Actions

- (void)updatePhoneNumber2ConverationWebHook:(NSString* )phoneNumber conversationName:(NSString* )conversationName handler:(void (^)(void))handler{
    NSString *post = [NSString stringWithFormat:@"phoneNumber=%@&conversation_name=%@",phoneNumber,conversationName];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://nexmo.vonage.il.wh.eu.ngrok.io.ngrok.io/phone2conversation?phoneNumber=%@&conversation_name=%@", phoneNumber, conversationName]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Got response %@ with error %@.\n", response, error);
            return;
        }
        
        // TODO: 413 Payload too lage
        if (((NSHTTPURLResponse *)response).statusCode != 200){
            NSLog(@"Got response %@ with error %@.\n", response, error);
            return;
        }
        
        
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        handler();
        
    }] resume];
    
    
}
- (IBAction)invitePstn:(id)sender{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Invite Pstn"
                                                                              message: @"Input phone number"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"phoneNumber";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        [self updatePhoneNumber2ConverationWebHook:[namefield text] conversationName:[self.conversation name] handler:^{
            [self.conversationManager.stitchConversationClient inviteToConversation:self.testUserNames[_userId] withPhoneNumber:[namefield text] onSuccess:^(NSString * _Nullable value) {
                                NSLog(@"success");
                            } onError:^(NSError * _Nullable error) {
                                NSLog(@"error ");
                            }];
        }];
        
        NSLog(@"%@",namefield.text);
        
    }]];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)addMemberPressed:(id)sender {
    NSMutableString *message = [NSMutableString new];
    if(self.membersController.myMember) {
        [message appendFormat:@"%@\n",self.membersController.myMember.name];
    }
    NSArray<NSString *> *membersIds = [[self.membersController.otherMembers valueForKey:@"name"] allObjects];
    [message appendFormat:@"%@\n",[membersIds componentsJoinedByString:@"\n"]];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"members" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"add user";
    }];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *username =[[alertController textFields][0] text];
        NSLog(@"username %@", username);
        
        NSString * userId = self.testUserIDs[username];
        __weak ConversationViewController *weakSelf = self;
        [self.conversation addMemberWithUserId:userId completion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
            if(error) {
                NSLog(@"failed adding user with Error: %@", error);
                [weakSelf showMessageWithTitle:@"error" andMessage:@"failed adding user" andDismissAfterSeconds:2];
                return;
            }
            NSLog(@"success add username %@", username);
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
    
    [self.conversationManager.stitchConversationClient stopTyping:self.conversation.conversationId memberId:self.membersController.myMember.memberId onSuccess:^{
    } onError:^(NSError * _Nullable error) {
        NSLog(@"error typing");
    }];
    
    [self.conversation sendText:self.textinput.text completion:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"msg failed");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textinput.editable = YES;
            });
            return;
        }
        NSLog(@"msg sent");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textinput.editable = YES;
            self.textinput.text = @"";
            [self.textinput endEditing:YES];
        });
    }];
}
- (IBAction)attachmentPressed:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData* data = UIImagePNGRepresentation(image);
    
    NSString *filename = [NSString stringWithFormat:@"IMAGE_%@.png", [[NSUUID UUID] UUIDString]];

    [self.conversation sendAttachmentOfType:NXMAttachmentTypeImage WithName:filename data:data completion:^(NSError * _Nullable error) {
        if(error) {
            NSLog(@"failed to upload image with error: %@", error);
            [self showMessageWithTitle:@"image upload" andMessage:@"Failed to upload image" andDismissAfterSeconds:2];
            return;
        }
        [self showMessageWithTitle:@"image upload" andMessage:@"image uploaded" andDismissAfterSeconds:2];
    }];
    
    //Or you can get the image url from AssetsLibrary
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initialization

-(void)updateWithConversation:(NXMConversation *)conversation {
    
    self.conversationManager = self.conversationManager ?: ConversationManager.sharedInstance; //happens before viewDidLoad
    self.kommsWrapper = self.kommsWrapper ?: KommsClients.sharedWrapperClient;
    self.conversation = conversation;

    self.navigationItem.title = self.conversation.displayName;
    NSSet<NSNumber *> *eventsToPresent = [[NSSet alloc] initWithObjects:@(NXMEventTypeText),@(NXMEventTypeImage),@(NXMEventTypeMessageStatus),@(NXMEventTypeMedia),@(NXMEventTypeMember),@(NXMEventTypeSip),@(NXMEventTypeGeneral), nil];
    
    self.eventsController = [conversation eventsControllerWithTypes:eventsToPresent andDelegate:self];
    [self.eventsController loadEarlierEventsWithMaxAmount:AMOUNT_OF_EVENTS_TO_LOAD_MORE completion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadDataSourceWithScrollFlag:YES];
        });
    }];
    
    self.membersController = [conversation membersControllerWithDelegate:self];
    if(self.membersController.myMember) {
        [self.conversationManager addLookupMemberId:self.membersController.myMember.memberId forUser:self.membersController.myMember.userId inConversation:conversation.conversationId];
        [self.conversationManager.memberIdToName setObject:self.membersController.myMember.name forKey:self.membersController.myMember.memberId];
    }
    for (NXMMember *member in self.membersController.otherMembers) {
        [self.conversationManager.memberIdToName setObject:member.name forKey:member.memberId];
    }
    //init conversationDetails - to be removed soon
    [self.conversationManager.stitchConversationClient getConversationDetails:self.conversation.conversationId onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
        self.conversationDetails = conversationDetails;
    } onError:^(NSError * _Nullable error) {
        NSLog(@"error get details");
    }];
}

#pragma mark - conversationEventsController delegate
- (void)nxmConversationEventsControllerDidChangeContent:(NXMConversationEventsController *_Nonnull)controller {
    [self reloadDataSourceWithScrollFlag:NO];
}

#pragma mark - conversationmembersController delegate
-(void)nxmConversationMembersController:(NXMConversationMembersController * _Nonnull)controller didChangeMember:(nonnull NXMMember *)member atIndex:(NSUInteger)index forChangeType:(NXMMembersControllerChangeType)type {
    switch (type) {
        case NXMMembersControllerChangeTypeAdded:
            
            
            break;
        case NXMMembersControllerChangeTypeRemoved:
            
            
            break;
        default:
            break;
    }
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.eventsController ? self.eventsController.events.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXMEvent *event = self.eventsController.events[indexPath.row];
    if (event.type == NXMEventTypeMember) {
        ConversationEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationEventCell"];
        [cell updateWithEvent:event];

        return cell;
    }
    
    if (event.type == NXMEventTypeMedia) {
        ConversationEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationEventCell"];
        [cell updateWithEvent:event memberName:[self.membersController memberForMemberId:event.fromMemberId].name];

        return cell;
    }
    if (event.type == NXMEventTypeText || event.type == NXMEventTypeImage) {
        ConversationTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationTextCell"];
        if (cell == nil) {
            cell = [[ConversationTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationTextCell"];
            cell.backgroundColor = self.tableView.backgroundColor;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        SenderType senderType = ([self.conversation.myMember.memberId isEqualToString:event.fromMemberId]) ? SenderTypeSelf : SenderTypeOther;
        
        ConversationTableCellMessageStatus messageStatus = ConversationTableCellMessageStatusNone; //this really should be handled better but not for now
        NXMMessageEvent *messageEvent = (NXMMessageEvent *)event;
        if(messageEvent.state) {
            if(messageEvent.state[@(NXMMessageStatusTypeSeen)].count != 0) {
                messageStatus = ConversationTableCellMessageStatusSeen;
            }
            if (messageEvent.state[@(NXMMessageStatusTypeDelivered)].count != 0) {
                messageStatus = ConversationTableCellMessageStatusDelivered;
            }
        }
        
        [cell updateWithEvent:event
                   senderType:senderType
                   memberName:[self.membersController memberForMemberId:event.fromMemberId].name
                messageStatus:messageStatus];
        return cell;
    }
    if (event.type == NXMEventTypeSip){
        ConversationEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationEventCell"];
        [cell updateWithEvent:event memberName:[self.membersController memberForMemberId:event.fromMemberId].name];
        
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NXMEvent *event = self.eventsController.events[indexPath.row];
    if (event.type == NXMEventTypeMember || event.type == NXMEventTypeMedia || event.type == NXMEventTypeSip) {
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
        if (!([self.membersController.myMember.memberId isEqualToString:event.fromMemberId])) {
            NXMMember *fromMember = [self.membersController memberForMemberId:event.fromMemberId];
            if(fromMember) {
            nameSize = [fromMember.name boundingRectWithSize:boundSize
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f]}
                                                        context:nil].size;
            }
        }
        
        return textSize.height + nameSize.height + 40.0f;
    }
    return 0.1f;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y < 0) {
        self.isLoadMoreRequested = true;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(!self.isLoadMoreRequested) {
        return;
    }
    
    if(scrollView.contentOffset.y > 0) {
        self.isLoadMoreRequested = NO;
        return;
    }
    
    [self.loadMoreActivityIndicator startAnimating];
    [self.eventsController loadEarlierEventsWithMaxAmount:AMOUNT_OF_EVENTS_TO_LOAD_MORE completion:^(NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadMoreActivityIndicator stopAnimating];
            self.isLoadMoreRequested = NO;
            if (error) {
                [self showMessageWithTitle:@"error" andMessage:@"failed loading more conversations" andDismissAfterSeconds:2];
                return;
            }
            
            [self reloadDataSourceWithScrollFlag:NO];
        });
    }];
}

#pragma mark - Gestures

- (void)handleTap:(UIGestureRecognizer *)recognizer {
   // [self.textinput endEditing:YES];
}

- (void)handleLongPress:(UIGestureRecognizer *)recognizer {
    CGPoint locationInView = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locationInView];
    NXMEvent *event = self.eventsController.events[indexPath.row];
    
    if (![event.fromMemberId isEqualToString:self.membersController.myMember.memberId]) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"conversation" message:@"do you want to delete this msg?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.conversationManager.stitchConversationClient deleteEvent:event.sequenceId conversationId:event.conversationId fromMemberId:event.fromMemberId onSuccess:^{
            
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error deleteText");
        }];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if (!self.sendButton.enabled && self.kommsWrapper.kommsClient.isConnected) {
        [self.conversationManager.stitchConversationClient startTyping:self.conversation.conversationId memberId:self.membersController.myMember.memberId onSuccess:^{
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error typing");
        }];
    }
    [self updateSendButtonIfNeeded];
}



#pragma mark - Helper Methods
- (void)reloadDataSourceWithScrollFlag:(BOOL)scrollFlag {
    NSInteger currentNumberOfRows = [self.tableView numberOfRowsInSection:0];
    [self.tableView reloadData];
    if(scrollFlag) {
        [self scrollToBottom];
    } else {
        NSUInteger newNumberOfRows = self.eventsController.events.count;
        NSInteger dif = newNumberOfRows - currentNumberOfRows - (currentNumberOfRows ? 0 : 1);
        if(dif > 0) {
            [self scrollToRow:dif position:UITableViewScrollPositionTop animated:NO];
        }
    }
}

- (void)scrollToBottom {
    if (!self.eventsController || self.eventsController.events.count == 0) {
        return;
    }
    [self scrollToRow:(self.eventsController.events.count - 1) position:UITableViewScrollPositionBottom animated:YES];
}

- (void)scrollToRow:(NSInteger)row position:(UITableViewScrollPosition)position animated:(BOOL)animated{
    if (!self.eventsController || self.eventsController.events.count == 0) {
        return;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow: row inSection: 0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:position animated:animated];
}

#pragma mark - Calls
- (IBAction)enableAudioPressed:(id)sender {
    if (self.isAudioEnabled) {
        self.isAudioEnabled = NO;
        [self.call turnOff];
        return;
    }
    
    self.isAudioEnabled = YES;
    [self startAudioAnimation];
    
    [self.kommsWrapper.kommsClient callToUsers:@[@"USR-effc7845-333c-4779-aeaf-fdbb4167f93c"] delegate:self completion:^(NSError * _Nullable error, NXMCall * _Nullable call) {
        self.call = call;
    }];
}

- (IBAction)ongoingCallsTrayVisibilityPressed:(id)sender {
    if(self.isOnGoingCallsViewTrayOpen) {
        [self closeOngoingCallsTray];
        
    } else {
        [self openOngoingCallsTray];
    }
}

- (void)enableOngoingCallsTray {
    [self  closeOngoingCallsTray];
    self.onGoingCallsTrayButtonHeightConstraint.constant = ONGOING_CALLS_BUTTON_VISIBLE_HEIGHT;
}

- (void)disableOngoingCallsTray {
    [self  closeOngoingCallsTray];
    self.onGoingCallsTrayButtonHeightConstraint.constant = 0;
}

- (void)closeOngoingCallsTray {
    self.isOnGoingCallsViewTrayOpen = NO;
    self.onGoingCallsContainerViewHeightConstraint.constant = 0;
    self.onGoingCallsView.alpha = 0.85;
    [self.onGoingCallsTrayButton setImage:[UIImage imageNamed:@"openOngoingCallsTrayIcon"] forState:UIControlStateNormal];
    [self.onGoingCallsView layoutIfNeeded];
}

- (void)openOngoingCallsTray {
    self.isOnGoingCallsViewTrayOpen = YES;
    self.onGoingCallsContainerViewHeightConstraint.constant = ONGOING_CALLS_OPEN_HEIGHT;
    self.onGoingCallsView.alpha = 1;
    [self.onGoingCallsTrayButton setImage:[UIImage imageNamed:@"closeOngoingCallsTrayIcon"] forState:UIControlStateNormal];
    [self.onGoingCallsView layoutIfNeeded];
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
                         if (self.isAudioEnabled) {
                             [self startAudioAnimation];
                         }
                     }];
}

#pragma mark - NXMCallDelegate

- (void)statusChanged {
    
}
- (void)holdChanged:(NXMCallParticipant *)participant isHold:(BOOL)isHold member:(NSString *)member {
    
}

- (void)muteChanged:(NXMCallParticipant *)participant isMuted:(BOOL)isMuted member:(NSString *)member {
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    OngoingCallsViewController *vc = [segue destinationViewController];
    [vc updateWithConversation:self.conversationDetails];
    // Pass the selected object to the new view controller.
}

-(void)showMessageWithTitle:(NSString *)title andMessage:(NSString *)message andDismissAfterSeconds:(NSUInteger)seconds {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    __weak ConversationViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
