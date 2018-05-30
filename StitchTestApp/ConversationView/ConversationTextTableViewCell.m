//
//  ConversationTextTableViewCell.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ConversationTextTableViewCell.h"
#import "NXMTextEvent.h"
@interface ConversationTextTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *fromText;
@property (weak, nonatomic) IBOutlet UILabel *toText;
@end
@implementation ConversationTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithEvent:(NXMEvent *)event {
    NSString* str = [[NSString alloc] initWithFormat:@"conversationId:%@ type:%ld id:%@",event.conversationId,(long)event.type,event.sequenceId];
    self.toText.text = str;
//    if (event.type == NXMEventTypeText) {
//        self.toText.text = ((NXMTextEvent *)event).text;
//    }
}

@end