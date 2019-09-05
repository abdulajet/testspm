//
//  NXMConversationDelegate.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMCoreEvents.h"
#import "NXMMember.h"

/*!
 @protocol NXMConversationUpdateDelegate
 
 @brief The NXMConversationUpdateDelegate protocol notify on member updates
 */
@protocol NXMConversationUpdateDelegate <NSObject>
@optional
/*!
 * @brief member properties updated.
 * @param member A NXMMember object, the member that updates.
 * @param type A NXMMemberUpdateType enum.
 */
- (void)memberUpdated:(nonnull NXMMember *)member forUpdateType:(NXMMemberUpdateType)type;
@end


/*!
 @protocol NXMConversationDelegate
 
 @brief The NXMConversationDelegate protocol notify on conversation events
 */
@protocol NXMConversationDelegate <NSObject>
@optional
#pragma events
- (void)didReceiveCustomEvent:(nonnull NXMCustomEvent *)event;
- (void)didReceiveTextEvent:(nonnull NXMTextEvent *)event;
- (void)didReceiveImageEvent:(nonnull NXMImageEvent *)event;
- (void)didReceiveMessageStatusEvent:(nonnull NXMMessageStatusEvent *)event;
- (void)didReceiveTypingEvent:(nonnull NXMTextTypingEvent *)event;
- (void)didReceiveMemberEvent:(nonnull NXMMemberEvent *)event;
- (void)didReceiveLegStatusEvent:(nonnull NXMLegStatusEvent *)event;
- (void)didReceiveMediaEvent:(nonnull NXMMediaEvent *)event;

#pragma conversation status
- (void)conversationExpired;
@end
