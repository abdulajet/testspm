//
//  NXMCallMemberPrivate.h
//  StitcClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMCallMember.h"
#import "NXMLegStatusEvent.h"

@protocol NXMCallProxy;

@interface NXMCallMember (NXMCallMemberPrivate)

- (instancetype)initWithMember:(NXMMember *)member andCallProxy:(id<NXMCallProxy>)callProxy;

- (void)memberUpdated;
- (void)callEnded;

@end
