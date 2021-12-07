//
//  NXMUser
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

@import Foundation;

/**
 * The NXMUser class represents a User. A User identifies a unique Nexmo user in the context of a Nexmo Application.
 */
@interface NXMUser : NSObject

/// A unique identifier for the user.
@property (nonatomic, copy, nonnull) NSString *uuid;

/// The user's name, username, unique within your Nexmo Application.
@property (nonatomic, copy, nonnull) NSString *name;

/// The user's display name.
@property (nonatomic, copy, nonnull) NSString *displayName;

/// The user's image URL.
@property (nonatomic, copy, nullable) NSString *imageUrl;

@end
