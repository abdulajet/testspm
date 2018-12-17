//
//  ContactsTableViewCell.m
//  NexmoTestApp
//
//  Created by Doron Biaz on 12/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ContactsTableViewCell.h"

@interface ContactsTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *avatarInitialsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;

@property (nonatomic) NTAUserInfo *userInfo;
@end

@implementation ContactsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithUserInfo:(NTAUserInfo *)userInfo {
    self.userInfo = userInfo;
    self.contactNameLabel.text = userInfo.displayName;
    self.avatarInitialsLabel.text = userInfo.initials;
}

@end
