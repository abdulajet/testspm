//
//  OnGoingCallsCollectionViewCell.h
//  StitchTestApp
//
//  Created by Doron Biaz on 8/13/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OngoingMedia.h"
#import "ConversationManager.h"

@interface OnGoingCallsCollectionViewCell : UICollectionViewCell

@property ConversationManager *conversationManager;

-(void)updateWithConversationManager:(ConversationManager *)conversationManager andOngoingMedia:(OngoingMedia *)media;

@end
