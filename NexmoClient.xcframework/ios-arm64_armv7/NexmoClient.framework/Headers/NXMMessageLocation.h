//
//  NXMMessageLocation.h
//  NexmoClient
//
//  Copyright © 2021 Vonage. All rights reserved.
//

@import Foundation;

/// Information about a location.
@interface NXMMessageLocation: NSObject

/// The longitude of the location.
@property (nonatomic, readonly, nonnull) NSString *longitude;

/// The latitude of the location.
@property (nonatomic, readonly, nonnull) NSString *latitude;

/// The name of the location.
@property (nonatomic, readonly, nullable) NSString *name;

/// The address of the location.
@property (nonatomic, readonly, nullable) NSString *address;

@end
