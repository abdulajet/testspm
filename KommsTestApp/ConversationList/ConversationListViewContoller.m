//
//  ConversationListViewContoller.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ConversationListViewContoller.h"
#import "ConversationListTableCellView.h"
#import "ConversationViewController.h"
#import "ConversationManager.h"
#import "KommsClientWrapper.h"
#import "KommsClients.h"
#import "AppDelegate.h"

@interface ConversationListViewContoller ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property ConversationManager *conversationManager;
@property KommsClientWrapper *kommsWrapper;
@property NSMutableArray<NXMConversationDetails *> *conversationsDetails;
//@property lastestId
@end

@implementation ConversationListViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversationManager = ConversationManager.sharedInstance;
    self.kommsWrapper = KommsClients.sharedWrapperClient;
    self.conversationsDetails =  [NSMutableArray new];
    [self getConversations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedMemberEvent:)
                                                 name:@"memberEvent"
                                               object:nil];
}

- (void)receivedMemberEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMemberEvent *member = userInfo[@"member"];
    if (!(member.state==NXMMemberStateInvited &&
        [member.user.name isEqualToString:self.conversationManager.connectedUser.name])) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"conversation" message:@"added to conversation" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.kommsWrapper.kommsClient getConversationWithId:member.conversationId completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
            if(error) {
                if(self.view.window) {
                    [self displayMessage:@"someone added you to a conversation. However conversation was not loaded" andTitle:@"habdeling memberEvent"];
                }
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NXMConversationDetails *conversationDetails =  [NXMConversationDetails new];
                conversationDetails.displayName = conversation.displayName;
                conversationDetails.conversationId = conversation.conversationId;
                [self.conversationsDetails insertObject:conversationDetails atIndex:0];
                
                [self.tableView reloadData];
                
                [self showConversation:conversation];
            });
        }];
    }];
    
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = [self.kommsWrapper.kommsClient getUser].name;
    [self subscribeLoginEvents];
}

- (IBAction)createConversationPressed:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create conversation" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"conversation name";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *displayName =[[alertController textFields][0] text];
        NSLog(@"conversation name %@", displayName);
        [self.kommsWrapper.kommsClient createConversationWithName:displayName completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
            if(error) {
                [self displayMessage:@"failed creating conversation" andTitle:@"server error"];
                return;
            }
            
            [conversation joinWithCompletion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
                if(error) {
                    [self displayMessage:@"failed joining conversation" andTitle:@"server error"];
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NXMConversationDetails *conversationDetails =  [NXMConversationDetails new];
                    conversationDetails.displayName = conversation.displayName;
                    conversationDetails.conversationId = conversation.conversationId;
                    
                    [self.conversationsDetails insertObject:conversationDetails atIndex:0];
                    
                    [self.tableView reloadData];
                    
                    [self showConversation:conversation];
                });
            }];
        }];
    }];
    
    
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];;
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationsDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationListTableCellView *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationListCell"];
    [cell updateWithConversation:self.conversationsDetails[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.kommsWrapper.kommsClient getConversationWithId:self.conversationsDetails[indexPath.row].conversationId completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
        if(error) {
            [self displayMessage:@"failed getting conversation for selection" andTitle:@"server error"];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showConversation:conversation];
        });
    }];
}
#pragma mark - Navigation



#pragma mark - Authentication events
- (void)subscribeLoginEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccessfulLogin:) name:@"loginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:@"logout" object:nil];
}

- (IBAction)onLogoutButtonPressed:(UIBarButtonItem *)sender {
    NSData *deviceToken = ((AppDelegate *)UIApplication.sharedApplication.delegate).deviceToken;
    if(!deviceToken) {
        [self.kommsWrapper.kommsClient logout];
        return;
    }
    
    [self.kommsWrapper.kommsClient disablePushNotificationsWithCompletion:^(NSError * _Nullable error) {
        if(error) {
            [self displayMessage:@"failed disabling notifications, not logging out" andTitle:@"push trouble"];
            return;
        }
        [self.kommsWrapper.kommsClient logout];

    }];
}

- (void)didLogout:(NSNotification *) notification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSuccessfulLogin:(NSNotification  *) notification{
    [self getConversations];
}
#pragma mark - Private

- (void)getConversations {
    //TODO: this is above the core instead of object model because no pagination and data returned is not the data we really need
    NSLog(@"get conversations %@", [self.kommsWrapper.kommsClient getUser]);
    
    [self.conversationManager.stitchConversationClient getConversationsForUser:self.conversationManager.connectedUser.userId
                            onSuccess:^(NSArray<NXMConversationDetails *> * _Nullable conversationsDetails, NXMPageInfo * _Nullable pageInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.conversationsDetails = [conversationsDetails mutableCopy];
            [self.tableView reloadData];
        });
    } onError:^(NSError * _Nullable error) {
        NSLog(@"%@", [NSString stringWithFormat:@"error get conversations %@", error]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"server error" message:@"failed please retry" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self getConversations];
            }];
            [alertController addAction:confirmAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }];
}

- (void)showConversation:(NXMConversation *)conversation {
    
    ConversationViewController *conversationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"conversationView"];
    [conversationVC updateWithConversation:conversation];
    
    [self.navigationController pushViewController:conversationVC animated:YES];
    //[self presentViewController:conversationVC animated:YES completion:nil];
}

-(void)displayMessage:(NSString *)message andTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    return;
}
@end

