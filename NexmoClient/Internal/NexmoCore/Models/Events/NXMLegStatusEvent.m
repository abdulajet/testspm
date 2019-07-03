//
//  NXMLogStatusEvent.m
//  NexmoClient
//
//  Created by Assaf Passal on 4/17/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMLegStatusEvent.h"
#import "NXMCoreEventsPrivate.h"

@interface NXMLegStatusEvent()
@property (nonatomic, readwrite, nonnull) NSMutableArray<NXMLeg *> *history;

@end
@implementation NXMLegStatusEvent

- (instancetype) initWithConversationId:(NSString *)conversationId
                                   type:(NXMEventType)type
                           fromMemberId:(NSString *)fromMemberId
                             sequenceId:(NSInteger)sequenceId
                             legHistory:(NSMutableArray<NXMLeg *> *)legs {
    if (self = [super initWithConversationId:conversationId sequenceId:sequenceId fromMemberId:fromMemberId creationDate:nil type:type]) {
        self.history = legs;
    }
    
    return self;
}

- (nonnull NXMLeg *)current {
    return [self.history lastObject];
}

@end
