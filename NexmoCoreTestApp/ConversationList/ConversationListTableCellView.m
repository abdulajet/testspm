//
//  ConversationListTableCellView.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ConversationListTableCellView.h"
@interface ConversationListTableCellView()

@property (weak, nonatomic) IBOutlet UILabel *conversationName;
@property (weak, nonatomic) IBOutlet UILabel *conversationDate;
@property NXMConversationDetails *conversation;

@end

@implementation ConversationListTableCellView  

- (NXMConversationDetails *)getConversation {
    return self.conversation;
}
-(void)updateWithConversation:(NXMConversationDetails*)conversation {
    self.conversation = conversation;

    if ([self.conversation.displayName length] > 0) {
        self.conversationName.text = self.conversation.displayName;
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
