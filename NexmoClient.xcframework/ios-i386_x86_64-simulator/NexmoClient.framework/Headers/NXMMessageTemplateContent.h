//
//  NXMMessageTemplateContent.h
//  NexmoClient
//
//  Copyright © 2021 Vonage. All rights reserved.
//

@import Foundation;

/// Information about a template content, used in `NXMMessageTemplateContent`.
@interface NXMMessageTemplateContent: NSObject

/// The name of the template.
@property (nonatomic, readonly, nonnull) NSString *name;

/// The parameters of the template.
@property (nonatomic, readonly, nullable) NSArray<NSString *> *parameters;

@end
