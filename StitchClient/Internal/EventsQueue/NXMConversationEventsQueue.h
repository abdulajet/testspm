//
//  ConversationEventsQueue.h
//  StitchObjC
//
//  Created by Iliya Barenboim on 26/08/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NXMEvent;

@protocol NXMConversationEventsQueueDelegate <NSObject>

@optional
- (void)handleEvent:(NXMEvent*_Nonnull)event;
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
