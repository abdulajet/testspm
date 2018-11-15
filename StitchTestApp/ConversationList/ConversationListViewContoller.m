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

@interface ConversationListViewContoller ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property ConversationManager *conversationManager;
@property NSMutableArray<NXMConversationDetails *> *conversations;
//@property lastestId
@end

@implementation ConversationListViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversationManager = ConversationManager.sharedInstance;
    self.conversations =  [NSMutableArray new];
    [self getNewestConversations];
    
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
        [self.conversationManager.stitchConversationClient getConversationDetails:member.conversationId onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.conversations insertObject:conversationDetails atIndex:0];
                
                [self.tableView reloadData];
                
                [self showConversation:conversationDetails];
            });
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error");
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
    self.navigationItem.title = self.conversationManager.connectedUser.name;
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
        
        [self.conversationManager.stitchConversationClient createConversationWithName:displayName onSuccess:^(NSString * _Nullable value) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NXMConversationDetails *conversation =  [NXMConversationDetails new];
                conversation.displayName = displayName;
                conversation.conversationId = value;
                
                [self.conversations insertObject:conversation atIndex:0];
                
                [self.tableView reloadData];
                
                [self showConversation:conversation];
            });
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error", displayName);
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
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationListTableCellView *cell = [self.tableView dequeueReusableCellWithIdentifier:@"conversationListCell"];
    [cell updateWithConversation:self.conversations[indexPath.row]];
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ConversationListTableCellView *cell = sender;
    
    ConversationViewController *vc = [segue destinationViewController];
    [vc updateWithConversation:[cell getConversation]];
}
#pragma mark - Authentication events
- (void)subscribeLoginEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSuccessfulLogin:) name:@"loginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogout:) name:@"logout" object:nil];
}

- (IBAction)onLogoutButtonPressed:(UIBarButtonItem *)sender {
    [self.conversationManager.stitchConversationClient disablePushNotificationsWithOnSuccess:^{
        [self.conversationManager.stitchConversationClient logout];
    } onError:^(NSError * _Nullable error) {
        NSLog(@"failed deisabling push with error: %@", error);
    }];
}

- (void)didLogout:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    NXMUser *user = userInfo[@"user"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSuccessfulLogin:(NSNotification  *) notification{
    NSDictionary *userInfo = notification.userInfo;
    NXMUser *user = userInfo[@"user"];
    [self getNewestConversations];
}
#pragma mark - Private

- (void)getNewestConversations {
    NXMGetConversationsRequest *request = [NXMGetConversationsRequest new];
    request.pageSize = 1;
    request.recordIndex = 0;
    
    NSLog(@"get conversation %@", self.conversationManager.connectedUser.userId);

    [self.conversationManager.stitchConversationClient getConversationsForUser:self.conversationManager.connectedUser.userId
                            onSuccess:^(NSArray<NXMConversationDetails *> * _Nullable conversationsDetails, NXMPageInfo * _Nullable pageInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.conversations addObjectsFromArray:conversationsDetails];

            [self.tableView reloadData];
        });
    } onError:^(NSError * _Nullable error) {
        NSLog(@"%@", [NSString stringWithFormat:@"error get conversations %@", error]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"server error" message:@"failed please retry" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self getNewestConversations];
            }];
            [alertController addAction:confirmAction];
            [self presentViewController:alertController animated:YES completion:nil];
        });

    }];
    

}

- (void)getConversationsDetails:(NSArray*)conversations {

    for (NXMConversationDetails *conv in conversations) {
        [self.conversationManager.stitchConversationClient getConversationDetails:conv.conversationId onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
            
        } onError:^(NSError * _Nullable error) {
            NSLog(@"get conversation error %@", error);
        }];
    }
}

- (void)showConversation:(NXMConversationDetails *)conversation {
    ConversationViewController *conversationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"conversationView"];
    [conversationVC updateWithConversation:conversation];
    
    [self.navigationController pushViewController:conversationVC animated:YES];
    //[self presentViewController:conversationVC animated:YES completion:nil];
}

@end

