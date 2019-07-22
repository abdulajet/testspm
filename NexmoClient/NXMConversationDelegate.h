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
 @protocol NXMConversationUpdatesDelegate
 
 @brief The NXMConversationUpdatesDelegate protocol notify on member updates
 */
@protocol NXMConversationUpdatesDelegate <NSObject>
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
- (void)customEvent:(nonnull NXMCustomEvent *)customEvent;
- (void)textEvent:(nonnull NXMMessageEvent *)textEvent;
- (void)attachmentEvent:(nonnull NXMMessageEvent *)attachmentEvent;
- (void)messageStatusEvent:(nonnull NXMMessageStatusEvent *)messageStatusEvent;
- (void)typingEvent:(nonnull NXMTextTypingEvent *)typingEvent;
- (void)memberEvent:(nonnull NXMMemberEvent *)memberEvent;
- (void)legStatusEvent:(nonnull NXMLegStatusEvent *)legStatusEvent;
- (void)mediaEvent:(nonnull NXMEvent *)mediaEvent;

#pragma conversation status
- (void)conversationExpired;
@end
