//
//  ContactsTableViewCell.h
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTAUserInfo.h"

NS_ASSUME_NONNULL_BEGIN
static NSString * const contactstableViewCellIdentifier = @"contactsCell";
@interface ContactsTableViewCell : UITableViewCell
- (void)updateWithUserInfo:(NTAUserInfo *)userInfo;
@end

NS_ASSUME_NONNULL_END
