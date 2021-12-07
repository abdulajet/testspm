//
//  NXMMessageTemplateWhatsapp.h
//  NexmoClient
//
//  Copyright © 2021 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Information about a whatsapp template, used in `NXMMessageTemplateWhatsapp`
 */
@interface NXMMessageTemplateWhatsapp : NSObject

/// The policy of the whatsapp.
@property (nonatomic, readonly, nonnull) NSString *policy;

/// The locale of the whatsapp.
@property (nonatomic, readonly, nonnull) NSString *locale;

@end
