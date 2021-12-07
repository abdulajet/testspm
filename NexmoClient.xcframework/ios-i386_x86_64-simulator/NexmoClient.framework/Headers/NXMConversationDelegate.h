//
//  NXMConversationDelegate.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "NXMCoreEvents.h"
#import "NXMMember.h"

@class NXMConversation;

/**
 The NXMConversationUpdateDelegate protocol notifies on member updates.
 */
@protocol NXMConversationUpdateDelegate <NSObject>

/**
 * Member properties updated.
 * @param member A `NXMMember` object, the member that updates.
 * @param type A `NXMMemberUpdateType` enum.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didUpdateMember:(nonnull NXMMember *)member withType:(NXMMemberUpdateType)type;
@end

/**
 The NXMConversationDelegate protocol notifies on conversation events.
 */
@protocol NXMConversationDelegate <NSObject>

/**
 * Received a conversation.
 * @param conversation A `NXMConversation` object, the conversation received.
 * @param error An error.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceive:(nonnull NSError *)error;
@optional
#pragma events

/**
 * Received a custom event.
 * @param conversation A `NXMConversation` object, the conversation which received the custom event.
 * @param event An `NXMCustomEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveCustomEvent:(nonnull NXMCustomEvent *)event;

/**
 * Received a text event.
 * @param conversation A `NXMConversation` object, the conversation which received the text event.
 * @param event An `NXMTextEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveTextEvent:(nonnull NXMTextEvent *)event;

/**
 * Received an image event.
 * @param conversation A `NXMConversation` object, the conversation which received the image event.
 * @param event An `NXMImageEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveImageEvent:(nonnull NXMImageEvent *)event;

/**
 * Received a message status event.
 * @param conversation A `NXMConversation` object, the conversation which received the message status event.
 * @param event An `NXMMessageStatusEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveMessageStatusEvent:(nonnull NXMMessageStatusEvent *)event;

/**
 * Received a typing event.
 * @param conversation A `NXMConversation` object, the conversation which received the typing event.
 * @param event An `NXMTextTypingEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveTypingEvent:(nonnull NXMTextTypingEvent *)event;

/**
 * Received a member event.
 * @param conversation A `NXMConversation` object, the conversation which received the member event.
 * @param event An `NXMMemberEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveMemberEvent:(nonnull NXMMemberEvent *)event;

/**
 * Received a leg status event.
 * @param conversation A `NXMConversation` object, the conversation which received the leg status event.
 * @param event An `NXMLegStatusEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveLegStatusEvent:(nonnull NXMLegStatusEvent *)event;

/**
 * Received a media event.
 * @param conversation A `NXMConversation` object, the conversation which received the media event.
 * @param event An `NXMMediaEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveMediaEvent:(nonnull NXMMediaEvent *)event;

/**
 * Received a DTMF event.
 * @param conversation A `NXMConversation` object, the conversation which received the DTMF event.
 * @param event An `NXMDTMFEvent` object.
 */
- (void)conversation:(nonnull NXMConversation *)conversation didReceiveDTMFEvent:(nonnull NXMDTMFEvent *)event;
@end
