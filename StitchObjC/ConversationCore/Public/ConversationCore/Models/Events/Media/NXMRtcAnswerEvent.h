//
//  NXMRtcAnswerEvent.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/2/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
//special event that goes directly to MiniRTC, no sequenceId, not going up to the developer
@interface NXMRtcAnswerEvent : NSObject


@property (nonatomic, strong, nonnull) NSString *conversationId;
@property (nonatomic, strong, nonnull) NSString *rtcId;
@property (nonatomic, strong, nonnull) NSString *sdp;
@property (nonatomic, strong, nonnull) NSString *sessionId;
@property (nonatomic, strong, nonnull) NSDate *timestamp;

@end
