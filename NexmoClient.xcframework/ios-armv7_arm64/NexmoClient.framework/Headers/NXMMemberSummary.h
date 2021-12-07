//
//  NXMMemberSummary.h
//  NexmoClient
//
//  Copyright © 2021 Vonage. All rights reserved.
//

@import Foundation;
#import "NXMEnums.h"

@class NXMUser;

/**
 * An individual conversation member.
 * Use this class to retrieve information about a NXMMemberSummary and display member info.
 */
@interface NXMMemberSummary: NSObject

/// Member's conversation ID.
@property (nonnull, readonly, nonatomic) NSString *conversationUuid;

/// The member's ID.
@property (nonnull, readonly, nonatomic) NSString *memberUuid;

/// The user.
@property (nonnull, readonly, nonatomic) NXMUser *user;

/// The member's state.
@property (nonatomic, readonly) NXMMemberState state;

@end
