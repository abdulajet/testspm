//
//  NXMConversationEventsController+Private.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEventsController.h"
#import "NXMStitchContext.h"

@interface NXMConversationEventsController (Private)
- (instancetype _Nonnull )initWithSubscribedEventsType:(NSSet *_Nonnull)eventsType andConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails andStitchContext:(NXMStitchContext * _Nonnull)stitchContext;

- (instancetype _Nonnull)initWithSubscribedEventsType:(NSSet *_Nonnull)eventsType andConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails andStitchContext:(NXMStitchContext * _Nonnull)stitchContext delegate:(id <NXMConversationEventsControllerDelegate> _Nullable)delegate;

@end
