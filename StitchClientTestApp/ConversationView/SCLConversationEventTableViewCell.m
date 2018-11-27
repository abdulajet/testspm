//
//  ConversationEventTableViewCell.m
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "SCLConversationEventTableViewCell.h"
#import <StitchClient/StitchClient.h>

@interface SCLConversationEventTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *eventText;
@property (weak, nonatomic) IBOutlet UIImageView *audioImage;
@property NXMEvent *event;
@property NSString *memberName;
@end
@implementation SCLConversationEventTableViewCell

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
        NSString *stateText = nil;
        switch (((NXMMemberEvent *)event).state) {
            case NXMMemberStateInvited:
                stateText = @"invited";
                break;
            case NXMMemberStateJoined:
                stateText = @"joined";
                break;
            case NXMMemberStateLeft:
                stateText = @"left";
                break;
            default:
                break;
        }
        NSString *text = [NSString stringWithFormat:@"%@ %@",
                          stateText, ((NXMMemberEvent *)event).user.name];
        self.eventText.text = text;
        self.eventText.textAlignment = NSTextAlignmentCenter;
        self.audioImage.image = [[UIImage alloc] init];
    }
    
    if (event.type == NXMEventTypeMedia) {
        //TODO: right media refers only to audio enable
        bool isAudioEnabled = ((NXMMediaEvent *)event).mediaSettings.isEnabled;
        
        NSString *text = [NSString stringWithFormat:@"Audio %@ by %@",
                          isAudioEnabled ? @"Enabled" : @"Disabled", memberName];
        self.eventText.text = text;
        self.eventText.textAlignment = NSTextAlignmentLeft;
        NSString *imageName = isAudioEnabled ? @"eventAudioEnabled" : @"eventAudioDisabled";
        self.audioImage.image = [UIImage imageNamed:imageName];
        
    }
    if (event.type == NXMEventTypeSip) {
        NSString *text = [NSString stringWithFormat:@"Call %@ by %@ [%ld]",
                          ((NXMSipEvent *)event).phoneNumber , memberName, (long)((NXMSipEvent*) event).sipType];
        self.eventText.text = text;
        self.eventText.textAlignment = NSTextAlignmentCenter;
    }
}

- (void)updateWithEvent:(NXMEvent *)event {
    [self updateWithEvent:event memberName:event.fromMemberId];
}
@end
