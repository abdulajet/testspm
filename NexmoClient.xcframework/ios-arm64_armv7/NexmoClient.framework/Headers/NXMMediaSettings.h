//
//  NXMMediaSettings.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The settings for the media of an `NXMMember`.
 */
@interface NXMMediaSettings : NSObject

/// Whether media is enabled or not.
@property (nonatomic, readonly) bool isEnabled;

/// Whether media is suspended or not.
@property (nonatomic, readonly) bool isSuspended;

@end
