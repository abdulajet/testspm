//
//  ConversationListViewContoller.m
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLConversationListViewContoller.h"
#import "SCLConversationListTableCellView.h"
#import "SCLConversationViewController.h"
#import "SCLStitchClientWrapper.h"
#import "SCLStitchClients.h"
#import "SCLAppDelegate.h"
//Hack to get conversations until Client supports getConversagtions
#import "SCLStitchClientWrapper+CoreExpose.h"

@interface SCLConversationListViewContoller ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property SCLStitchClientWrapper *kommsWrapper;
@property NSMutableArray<NXMConversationDetails *> *conversationsDetails;

@property NSDictionary<NSString *,NSString *> * testUserIDs;
@property NSDictionary<NSString *,NSString *> * testUserNames;

//@property lastestId
@end

@implementation SCLConversationListViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.kommsWrapper = SCLStitchClients.sharedWrapperClient;
    self.conversationsDetails =  [NSMutableArray new];
    [self getConversations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedMemberEvent:)
                                                 name:@"memberEvent"
                                               object:nil];
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
}

- (void)receivedMemberEvent:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMMemberEvent *member = userInfo[@"member"];
    if (!(member.state==NXMMemberStateInvited &&
        [member.user.name isEqualToString:self.kommsWrapper.kommsClient.user.name])) {
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
    self.navigationItem.title = self.kommsWrapper.kommsClient.user.name;
    [self subscribeLoginEvents];
}

- (IBAction)createCallPressed:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create call" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"users name";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *displayName =[[alertController textFields][0] text];
        NSLog(@"users name %@", displayName);
        NSArray *names = [(NSString*)displayName componentsSeparatedByString:@";"];
        NSMutableArray *namesIds = [NSMutableArray arrayWithArray:names];
        for (int i= 0 ; i < names.count; i++){
            namesIds[i] = self.testUserIDs[names[i]];
        }
        [self.kommsWrapper.kommsClient callToUsers:namesIds delegate:nil completion:^(NSError * _Nullable error, NXMCall * _Nullable call) {
            
        }];
    }];

    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancelled");
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];;
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
    SCLConversationListTableCellView *cell = [self.tableView dequeueReusableCellWithIdentifier:@"sclConversationListCell"];
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
    NSLog(@"get conversations %@", self.kommsWrapper.kommsClient.user);
    
    [self.kommsWrapper getConversationsForUser:self.kommsWrapper.kommsClient.user.userId
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
    
    SCLConversationViewController *conversationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"conversationView"];
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

