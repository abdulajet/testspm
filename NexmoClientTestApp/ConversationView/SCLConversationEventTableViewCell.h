//
//  ConversationEventTableViewCell.h
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NXMEvent;
@interface SCLConversationEventTableViewCell : UITableViewCell

- (void)updateWithEvent:(NXMEvent *)event;
- (void)updateWithEvent:(NXMEvent *)event memberName:(NSString *)memberName;

@end
