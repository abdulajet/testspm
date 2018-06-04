//
//  ConversationEventTableViewCell.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "ConversationEventTableViewCell.h"
#import "NXMMemberEvent.h"
#import "NXMMediaEvent.h"

@interface ConversationEventTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *eventText;
@property NXMEvent *event;
@end
@implementation ConversationEventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithEvent:(NXMEvent *)event {
    self.event = event;
    
    if (event.type == NXMEventTypeMember) {
        NSString *text = [NSString stringWithFormat:@"%@ %@",
        ((NXMMemberEvent *)event).state, ((NXMMemberEvent *)event).user.name];
        self.eventText.text = text;
    }
    
    if (event.type == NXMEventTypeMedia) {
        NSString *text = [NSString stringWithFormat:@"audio %@ by %@",
                          ((NXMMediaEvent *)event).isMediaEnabled ? @"enabled" : @"disabled",((NXMMediaEvent *)event).fromMemberId];
        self.eventText.text = text;
    }
}
@end
