//
//  NXMMessageEvent.h
//  NexmoClient
//
//  Copyright © 2021 Vonage. All rights reserved.
//

#import "NXMEvent.h"

@class NXMMessageTemplateContent;
@class NXMMessageTemplateWhatsapp;
@class NXMMessageLocation;

/**
 * Represents a message event that is sent and received on an `NXMConversation`.
 */
@interface NXMMessageEvent: NXMEvent

/// The type of the message.
@property (nonatomic, readonly) NXMMessageType messageType;

/// The content of the message.
@property (nonatomic, readonly, nonnull) NSDictionary *content;

/// The text of the message in case message_type is text.
@property (nonatomic, readonly, nullable) NSString *text;

/// The url of the message in case message_type is image.
@property (nonatomic, readonly, nullable) NSString *imageUrl;

/// The url of the message in case message_type is vcard.
@property (nonatomic, readonly, nullable) NSString *vcardUrl;

/// The url of the message in case message_type is audio.
@property (nonatomic, readonly, nullable) NSString *audioUrl;

/// The url of the message in case message_type is video.
@property (nonatomic, readonly, nullable) NSString *videoUrl;

/// The url of the message in case message_type is file.
@property (nonatomic, readonly, nullable) NSString *fileUrl;

/// The template content of the message in case message_type is template.
@property (nonatomic, readonly, nullable) NXMMessageTemplateContent *templateContent;

/// The whatsapp content of the message in case message_type is template.
@property (nonatomic, readonly, nullable) NXMMessageTemplateWhatsapp *templateWhatsapp;

/// The custom content of the message in case message_type is custom.
@property (nonatomic, readonly, nullable) NSDictionary *custom;

/// The location content of the message in case message_type is location.
@property (nonatomic, readonly, nullable) NXMMessageLocation *location;

@end
