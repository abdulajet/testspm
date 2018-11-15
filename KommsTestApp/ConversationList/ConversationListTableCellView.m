//
//  ConversationListTableCellView.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ConversationListTableCellView.h"
#import <StitchClient/StitchClient.h>

@interface ConversationListTableCellView()

@property (weak, nonatomic) IBOutlet UILabel *conversationName;
@property (weak, nonatomic) IBOutlet UILabel *conversationDate;
@property NXMConversationDetails *conversationDetails;

@end

@implementation ConversationListTableCellView  

- (NXMConversationDetails *)getConversation {
    return self.conversationDetails;
}
-(void)updateWithConversation:(NXMConversationDetails *)conversation {
    self.conversationDetails = conversation;

    if ([self.conversationDetails.displayName length] > 0) {
        self.conversationName.text = self.conversationDetails.displayName;
        return;
    }
    
    self.conversationName.text = conversation.conversationId;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
