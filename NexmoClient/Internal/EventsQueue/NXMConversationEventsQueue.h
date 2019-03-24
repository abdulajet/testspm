//
//  ConversationEventsQueue.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMCoreEvents.h"

@protocol NXMConversationEventsQueueDelegate <NSObject>

- (void)handleEvent:(NXMEvent*_Nonnull)event;
- (void)conversationExpired;
@optional
- (void)finishHandleEventsSequence;

@end

@class NXMConversationDetails;
@class NXMStitchContext;
@interface NXMConversationEventsQueue : NSObject

@property (weak,nonatomic, nullable) id <NXMConversationEventsQueueDelegate> delegate;
@property (nonatomic, readonly) NSInteger sequenceIdSyncingFrom;

- (nullable instancetype)initWithConversationDetails:(nonnull NXMConversationDetails*)ConversationDetails
                                       stitchContext:(nonnull NXMStitchContext*)stitchContext;

- (nullable instancetype)initWithConversationDetails:(nonnull NXMConversationDetails*)ConversationDetails
                                    stitchContext:(nonnull NXMStitchContext*)stitchContext
                                            delegate:(_Nullable id <NXMConversationEventsQueueDelegate>)delegate;
@end
