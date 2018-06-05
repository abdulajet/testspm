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
@property (weak, nonatomic) IBOutlet UIImageView *audioImage;
@property NXMEvent *event;
@property NSString *memberName;
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

- (void)updateWithEvent:(NXMEvent *)event memberName:(NSString *)memberName {
    self.event = event;
    
    if (event.type == NXMEventTypeMember) {
        NSString *text = [NSString stringWithFormat:@"%@ %@",
                          ((NXMMemberEvent *)event).state, ((NXMMemberEvent *)event).user.name];
        self.eventText.text = text;
        self.eventText.textAlignment = NSTextAlignmentCenter;
        self.audioImage.image = [[UIImage alloc] init];
    }
    
    if (event.type == NXMEventTypeMedia) {
        NSString *text = [NSString stringWithFormat:@"Audio %@ by %@",
                          ((NXMMediaEvent *)event).isMediaEnabled ? @"Enabled" : @"Disabled", memberName];
        self.eventText.text = text;
        self.eventText.textAlignment = NSTextAlignmentLeft;
        NSString *imageName = ((NXMMediaEvent *)event).isMediaEnabled ? @"eventAudioEnabled" : @"eventAudioDisabled";
        self.audioImage.image = [UIImage imageNamed:imageName];
    }
}

- (void)updateWithEvent:(NXMEvent *)event {
    [self updateWithEvent:event memberName:event.fromMemberId];
}
@end
