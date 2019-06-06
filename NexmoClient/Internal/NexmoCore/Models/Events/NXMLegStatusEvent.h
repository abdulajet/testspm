//
//  NXMLegStatusEvent.h
//  NXMiOSSDK
//
//  Created by Assaf Passal on 4/17/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEvent.h"
#import "NXMEnums.h"
#import "NXMLeg.h"

@interface NXMLegStatusEvent : NXMEvent

- (instancetype) initWithConversationId:(NSString*) conversationId
                                   type:(NXMEventType)type
                           fromMemberId:(NSString *)fromMemberId
                             sequenceId:(NSInteger)sequenceId
                             legHistory:(NSMutableArray<NXMLeg*>*) legs;

@property (nonatomic, readonly, nonnull) NSMutableArray<NXMLeg *> *history;
@property (nonatomic, readonly, nonnull) NXMLeg *current;

@end

