//
//  NXMLegStatusEvent.h
//  NXMiOSSDK
//
//  Created by Assaf Passal on 4/17/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMEvent.h"
#import "NXMEnums.h"
#import "NXMLeg.h"

/**
 * Represents a leg status event that can be received on an `NXMConversation`.
 */
@interface NXMLegStatusEvent : NXMEvent

/// A list of previous legs.
@property (nonatomic, readonly, nonnull) NSMutableArray<NXMLeg *> *history;

/// The current leg.
@property (nonatomic, readonly, nonnull) NXMLeg *current;

@end

