//
//  NXMPinningConfig.h
//  NexmoClient
//
//  Created by Nicola Di Pol on 19/11/2021.
//  Copyright © 2021 Vonage. All rights reserved.
//

@import Foundation;

/// SSL pinning configuration.
@interface NXMPinningConfig: NSObject

/// Create a pinning configuration from public key SHA256 hashes.
+ (nonnull NXMPinningConfig *)fromPublicKeys:(nonnull NSArray<NSString *> *)publicKeys;

@end
