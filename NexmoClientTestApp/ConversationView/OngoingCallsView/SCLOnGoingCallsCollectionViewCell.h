//
//  OnGoingCallsCollectionViewCell.h
//  StitchTestApp
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCLOngoingMedia.h"
#import "SCLConversationManager.h"

@interface SCLOnGoingCallsCollectionViewCell : UICollectionViewCell

@property SCLConversationManager *conversationManager;

-(void)updateWithConversationManager:(SCLConversationManager *)conversationManager andOngoingMedia:(SCLOngoingMedia *)media;

@end
