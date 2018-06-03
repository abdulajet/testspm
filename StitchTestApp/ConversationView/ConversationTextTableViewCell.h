//
//  ConversationTextTableViewCell.h
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXMEvent.h"

static CGFloat const kBubbleWidthOffset = 30.0f;
static CGFloat const kBubbleImageSize = 50.0f;

typedef NS_ENUM(NSUInteger, SenderType) {
    SenderTypeSelf,
    SenderTypeOther
};

@class NXMEvent;
@interface ConversationTextTableViewCell : UITableViewCell

- (void)updateWithEvent:(NXMEvent *)event senderType:(SenderType)senderType;

@end
