//
//  ConversationListViewContoller.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ConversationListViewContoller.h"
#import "AppDelegate.h"
#import "ConversationListTableCellView.h"
#import "CoversationViewController.h"

@interface ConversationListViewContoller ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property StitchConversationClientCore *stitch;
@property NSMutableArray<NXMConversationDetails *> *conversations;
//@property lastestId
@end

@implementation ConversationListViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);
    self.stitch = appDelegate.stitchConversation;
    self.conversations =  [NSMutableArray new];
    [self getNewestConversations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    

}

- (IBAction)createConversationPressed:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create conversation" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"conversation name";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *displayName =[[alertController textFields][0] text];
        NSLog(@"conversation name %@", displayName);
        
        [self.stitch createWithName:displayName onSuccess:^(NSString * _Nullable value) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NXMConversationDetails *conversation =  [NXMConversationDetails new];
                conversation.name = displayName;
                conversation.uuid = @"CON-432d5780-6181-4bb6-87d5-2e16c2b41df0"; //value;
                
                [self.conversations addObject:conversation];
                
                [self.tableView reloadData];
                
                [self showConversation:conversation];
            });
        } onError:^(NSError * _Nullable error) {
            NSLog(@"error", displayName);
        }];
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
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
    
    CoversationViewController *vc = [segue destinationViewController];
    [vc updateWithConversation:[cell getConversation]];
}


#pragma mark - Private

- (void)getNewestConversations {
    NXMGetConversationsRequest *request = [NXMGetConversationsRequest new];
    request.pageSize = 1;
    request.recordIndex = 0;
    [self.stitch getConversations:request onSuccess:^(NSArray<NXMConversationDetails *> * _Nullable conversationDetails, NXMPageInfo * _Nullable pageInfo) {
        
//        NXMGetConversationsRequest *newestRequest = [NXMGetConversationsRequest new];
//        request.pageSize = 1;
//        request.recordIndex = 0;
//        [self.stitch getConversations:request onSuccess:^(NSArray<NXMConversationDetails *> * _Nullable conversationDetails, NXMPageInfo * _Nullable pageInfo) {
//
//        } onError:^(NSError * _Nullable error) {
//
//        }];
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.conversations addObjectsFromArray:conversationDetails];

            [self.tableView reloadData];
        });
    } onError:^(NSError * _Nullable error) {
        NSLog(@"%@", [NSString stringWithFormat:@"error get conversations %@", error]);
    }];
}

- (void)getConversationsDetails:(NSArray*)conversations {

    for (NXMConversationDetails *conv in conversations) {
        [self.stitch getConversationDetails:conv.uuid onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
            
        } onError:^(NSError * _Nullable error) {
            NSLog(@"get conversation error %@", error);
        }];
    }
}

- (void)showConversation:(NXMConversationDetails *)conversation {
    CoversationViewController *conversationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"conversationView"];
    [conversationVC updateWithConversation:conversation];
    
    [self.navigationController pushViewController:conversationVC animated:YES];
    //[self presentViewController:conversationVC animated:YES completion:nil];
}

@end

