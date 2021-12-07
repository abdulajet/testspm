//
//  NXMMessage.h
//  NexmoClient
//
//  Created by user on 10/11/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

@import Foundation;
#import "NXMEnums.h"

/**
  The NXMMessage object represents a message to send.
*/
@interface NXMMessage: NSObject

/// Message type.
@property (nonatomic, readonly) NXMMessageType messageType;

/**
 Create a message from a generic dictionary.
 @param content A generic dictionary reporesenting the entire message content.
 */
- (nonnull instancetype)initWithContent:(nonnull NSDictionary *)content;

/**
 Create a message of NXMMessageTypeText type from a text.
 @param text The message text.
 */
- (nonnull instancetype)initWithText:(nonnull NSString *)text;

/**
 Create a message of NXMMessageTypeImage type.
 @param imageUrl The message image url string.
 */
- (nonnull instancetype)initWithImageUrl:(nonnull NSString *)imageUrl;

/**
 Create a message of NXMMessageTypeVideo type.
 @param videoUrl The message video url string.
 */
- (nonnull instancetype)initWithVideoUrl:(nonnull NSString *)videoUrl;

/**
 Create a message of NXMMessageTypeFile type.
 @param fileUrl The message file url string.
 */
- (nonnull instancetype)initWithFileUrl:(nonnull NSString *)fileUrl;

/**
 Create a message of NXMMessageTypeVcard type.
 @param vcardUrl The message vcard url string.
 */
- (nonnull instancetype)initWithVCardUrl:(nonnull NSString *)vcardUrl;

/**
 Create a message of NXMMessageTypeTemplate type.
 @param templateName The template name.
 @param templateParameters The template parameters.
 @param whatsappPolicy The template WhatsApp policy.
 @param whatsappLocale The template WhatsApp locale.
 */
- (nonnull instancetype)initWithTemplateName:(nonnull NSString *)templateName
                          templateParameters:(nullable NSArray<NSString *> *)templateParameters
                              whatsappPolicy:(nonnull NSString *)whatsappPolicy
                              whatsappLocale:(nonnull NSString *)whatsappLocale;

/**
 Create a message of NXMMessageTypeCustom type.
 @param custom The message custom content dictionary.
 */
- (nonnull instancetype)initWithCustom:(nonnull NSDictionary *)custom;

/**
 Create a message of NXMMessageTypeLocation type.
 @param longitude The longitude.
 @param latitude The latitude.
 @param name The name.
 @param address The address.
 */
- (nonnull instancetype)initWithLongitude:(nonnull NSString *)longitude
                                 latitude:(nonnull NSString *)latitude
                                     name:(nullable NSString *)name
                                  address:(nullable NSString *)address;

@end
