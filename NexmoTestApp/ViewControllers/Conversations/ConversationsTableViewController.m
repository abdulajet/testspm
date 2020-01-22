//
//  ConversationsTableViewController.m
//  NexmoTestApp
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "ConversationsTableViewController.h"
#import "CommunicationsManager.h"
#import "EventsTableViewController.h"

static NSUInteger const CONVERSATIONS_PAGE_SIZE = 3;
static NSString *const CONVERSATION_REUSE_ID = @"conversationReuseId";
static NSString *const CONVERSATIONS_TITLE_FORMAT = @"Conversations [%@]";

@interface ConversationsTableViewController ()

@property (nonatomic, assign) NXMPageOrder order;
@property (nonatomic, nullable) NXMConversationsPage *conversationsPage;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *previousPageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleOrderButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *nextPageButton;
@property UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ConversationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    UIView *tableViewFooter = [UIView new];
    tableViewFooter.backgroundColor = UIColor.whiteColor;
    self.tableView.tableFooterView = tableViewFooter;

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    self.order = NXMPageOrderAsc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self cleanAndGetConversationsPage];
}

- (IBAction)previousPageButtonPressed:(UIBarButtonItem *)sender {
    if ([self.conversationsPage hasPreviousPage]) {
        [self showActivityIndicatorView];

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
    [self cleanAndGetConversationsPage];
}

- (IBAction)nextPageButtonPressed:(UIBarButtonItem *)sender {
    if ([self.conversationsPage hasNextPage]) {
        [self showActivityIndicatorView];

        __weak typeof(self) weakSelf = self;
        [self.conversationsPage nextPage:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
            [weakSelf showPage:(error || !page) ? nil : page];
        }];
    } else {
        NSLog(@"❌ This is the LAST page: no next page available! ❌");
    }
}

- (void)showActivityIndicatorView {
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicatorView.hidden = NO;
    self.activityIndicatorView.hidesWhenStopped = NO;
    [self.view addSubview: self.activityIndicatorView];
    [self.view bringSubviewToFront:self.activityIndicatorView];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicatorView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicatorView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    [self.activityIndicatorView startAnimating];
}

- (void)hideActivityIndicatorView {
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
}

- (void)getConversationsPage {
    [self showActivityIndicatorView];

    NXMClient *client = CommunicationsManager.sharedInstance.client;
    __weak ConversationsTableViewController *weakSelf = self;
    [client getConversationsPageWithSize:CONVERSATIONS_PAGE_SIZE
                                   order:self.order
                       completionHandler:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
                           [weakSelf showPage:(error || !page) ? nil : page];
                       }];
}

- (void)cleanAndGetConversationsPage {
    __weak ConversationsTableViewController *weakSelf = self;
    [self showPage:nil completion:^{
        [weakSelf getConversationsPage];
    }];
}

- (void)showPage:(nullable NXMConversationsPage *)page {
    [self showPage:page completion:nil];
}

- (void)showPage:(nullable NXMConversationsPage *)page completion:(void(^_Nullable)(void))completion {
    NSString *orderString = self.order == NXMPageOrderAsc ? @"ASC" : @"DESC";
    self.conversationsPage = page;
    BOOL isThereAtLeastOneConversation = self.conversationsPage.conversations.count > 0;
    __weak ConversationsTableViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.navigationItem.title = [NSString stringWithFormat:CONVERSATIONS_TITLE_FORMAT, orderString];
        [weakSelf.tableView reloadData];
        if (isThereAtLeastOneConversation) {
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }

        [weakSelf hideActivityIndicatorView];

        if (completion) {
            completion();
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventsTableViewController *eventsTableViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EventsTableViewController"];
    eventsTableViewController.conversation = [self.conversationsPage conversations][indexPath.row];
    [self.navigationController pushViewController:eventsTableViewController animated:YES];
}

@end
