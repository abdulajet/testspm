//
//  ConversationsTableViewController.m
//  NexmoTestApp
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "ConversationsTableViewController.h"
#import "CommunicationsManager.h"

static NSUInteger const CONVERSATIONS_PAGE_SIZE = 3;
static NSString *const CONVERSATION_REUSE_ID = @"conversationReuseId";
static NSString *const CONVERSATIONS_TITLE_FORMAT = @"Conversations [%@]";

@interface ConversationsTableViewController ()

@property (nonatomic, assign) NXMPageOrder order;
@property (nonatomic, nullable) NXMConversationsPage *conversationsPage;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *previousPageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleOrderButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *nextPageButton;

@end

@implementation ConversationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.tableView.allowsSelection = NO;
    UIView *tableViewFooter = [UIView new];
    tableViewFooter.backgroundColor = UIColor.whiteColor;
    self.tableView.tableFooterView = tableViewFooter;

    self.order = NXMPageOrderAsc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self showPage:nil];
    [self getConversationsPage];
}

- (IBAction)previousPageButtonPressed:(UIBarButtonItem *)sender {
    if ([self.conversationsPage hasPreviousPage]) {
        __weak ConversationsTableViewController *weakSelf = self;
        [self.conversationsPage previousPage:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
            [weakSelf showPage:(error || !page) ? nil : page];
        }];
    } else {
        NSLog(@"❌ This is the FIRST page: no previous page available! ❌");
    }
}

- (IBAction)toggleOrderButtonPressed:(UIBarButtonItem *)sender {
    [self toggleOrder];
    [self showPage:nil];
    [self getConversationsPage];
}

- (IBAction)nextPageButtonPressed:(UIBarButtonItem *)sender {
    if ([self.conversationsPage hasNextPage]) {
        __weak typeof(self) weakSelf = self;
        [self.conversationsPage nextPage:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
            [weakSelf showPage:(error || !page) ? nil : page];
        }];
    } else {
        NSLog(@"❌ This is the LAST page: no next page available! ❌");
    }
}

- (void)getConversationsPage {
    NXMClient *client = CommunicationsManager.sharedInstance.client;
    __weak ConversationsTableViewController *weakSelf = self;
    [client getConversationsPageWithSize:CONVERSATIONS_PAGE_SIZE
                                   order:self.order
                       completionHandler:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
                           [weakSelf showPage:(error || !page) ? nil : page];
                       }];
}

- (void)showPage:(nullable NXMConversationsPage *)page {
    NSString *orderString = self.order == NXMPageOrderAsc ? @"ASC" : @"DESC";
    self.conversationsPage = page;
    
    BOOL isThereAtLeastOneConversation = self.conversationsPage.conversations.count > 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.title = [NSString stringWithFormat:CONVERSATIONS_TITLE_FORMAT, orderString];
        
        [self.tableView reloadData];
        if (isThereAtLeastOneConversation) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }
    });
}

- (void)toggleOrder {
    self.order = self.order == NXMPageOrderAsc ? NXMPageOrderDesc : NXMPageOrderAsc;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    NSArray<NXMConversation *> *conversations = [self.conversationsPage conversations];
    return conversations ? conversations.count : 0;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CONVERSATION_REUSE_ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                      reuseIdentifier: CONVERSATION_REUSE_ID];
    }
    cell.textLabel.numberOfLines = 0;
    NXMConversation *conversation = [self.conversationsPage conversations][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Name: %@\nID: %@",
                           conversation.displayName ?: @"-",
                           conversation.uuid ?: @"-"];
    return cell;
}

@end
