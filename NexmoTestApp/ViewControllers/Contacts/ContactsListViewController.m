//
//  ContactsViewController.m
//  NexmoTestApp
//
//  Created by Chen Lev on 12/9/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ContactsListViewController.h"
#import "ContactsListTableViewCell.h"
#import "NTAUserInfoProvider.h"
#import "NTALoginHandler.h"

@interface ContactsListViewController ()<UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *contactsTableView;

@property (nonatomic) NSArray<NTAUserInfo *> *contactsList;
@end

@implementation ContactsListViewController

- (void)viewDidLoad {
    self.contactsList = [self sortedContactsArray];
    [self.contactsTableView setDataSource:self];
    [self.contactsTableView reloadData];
}

#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(![tableView isEqual:self.contactsTableView]) {
        return 0;
    }
    
    return self.contactsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(![tableView isEqual:self.contactsTableView]) {
        return 0;
    }
    
    ContactsListTableViewCell *contactsCell = [self.contactsTableView dequeueReusableCellWithIdentifier:contactstableViewCellIdentifier];
    [contactsCell updateWithUserInfo:self.contactsList[indexPath.row]];
    
    return contactsCell;
}

- (NSArray<NTAUserInfo *> *)sortedContactsArray {
    NSArray<NTAUserInfo *> *users = [NTAUserInfoProvider getAllUsers];
    NSMutableArray<NTAUserInfo *> *mutableUsers = [users mutableCopy];
    NSUInteger indexOfSelf = [mutableUsers indexOfObject:[NTALoginHandler currentUser]];
    if(indexOfSelf) {
        [mutableUsers removeObject:[NTALoginHandler currentUser]];
    }
    return [mutableUsers sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NTAUserInfo *userInfo1 = (NTAUserInfo *)obj1;
        NTAUserInfo *userInfo2 = (NTAUserInfo *)obj2;

        return [userInfo1.displayName compare:userInfo2.displayName];
    }];
}
@end
