//
//  NXMMediaSettingsInternal.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

@interface NXMMediaSettings (Internal)

- (instancetype)initWithEnabled:(BOOL)enabled suspend:(BOOL)suspend;

- (void)updateWithEnabled:(BOOL)enabled suspend:(BOOL)suspend;
@end
