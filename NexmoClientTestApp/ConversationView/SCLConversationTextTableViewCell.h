//
//  ConversationTextTableViewCell.h
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXMEvent;

static CGFloat const kBubbleWidthOffset = 30.0f;
static CGFloat const kBubbleImageSize = 50.0f;

typedef NS_ENUM(NSUInteger, SCLSenderType) {
    SCLSenderTypeSelf,
    SCLSenderTypeOther
};

typedef NS_ENUM(NSUInteger, SCLConversationTableCellMessageStatus) {
    SCLConversationTableCellMessageStatusNone,
    SCLConversationTableCellMessageStatusSeen,
    SCLConversationTableCellMessageStatusDelivered,
    SCLConversationTableCellMessageStatusDeleted
};

@class NXMEvent;
@interface SCLConversationTextTableViewCell : UITableViewCell

- (void)updateWithEvent:(NXMEvent *)event
             senderType:(SCLSenderType)senderType
             memberName:(NSString *)memberName
          messageStatus:(SCLConversationTableCellMessageStatus)status;
@end
