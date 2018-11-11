//
//  NXMConversationEventsController+Private.h
//  StitchObjC
//
//  Created by Doron Biaz on 10/11/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEventsController.h"

@interface NXMConversationEventsController (Private)
- (instancetype _Nonnull )initWithSubscribedEventsType:(NSSet<NSNumber*>*_Nonnull)eventsType andConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails andStitchContext:(NXMStitchContext * _Nonnull)stitchContext;

- (instancetype _Nonnull)initWithSubscribedEventsType:(NSSet<NSNumber*>*_Nonnull)eventsType andConversationDetails:(NXMConversationDetails * _Nonnull)conversationDetails andStitchContext:(NXMStitchContext * _Nonnull)stitchContext delegate:(id <NXMConversationEventsControllerDelegate> _Nullable)delegate;

@end
