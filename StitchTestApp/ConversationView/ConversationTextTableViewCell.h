//
//  ConversationTextTableViewCell.h
//  StitchTestApp
//
//  Created by Chen Lev on 5/28/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXMEvent.h"

@class NXMEvent;
@interface ConversationTextTableViewCell : UITableViewCell

- (void)updateWithEvent:(NXMEvent *)event;
@end
