//
//  NXMLogStatusEvent.m
//  NexmoClient
//
//  Created by Assaf Passal on 4/17/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMUtils.h"
#import "NXMLegStatusEvent.h"
#import "NXMCoreEventsPrivate.h"
#import "NXMLegPrivate.h"

@interface NXMLegStatusEvent()
@property (nonatomic, readwrite, nonnull) NSMutableArray<NXMLeg *> *history;

@end
@implementation NXMLegStatusEvent

- (instancetype) initWithConversationId:(NSString*) conversationId
                                andData:(NSDictionary *)data {
    NSMutableArray<NXMLeg*> *legs = [[NSMutableArray<NXMLeg*> alloc] init];
    for (NSDictionary* currLeg in [data[@"body"] objectForKey:@"statusHistory"]) {
        NXMLeg* leg = [[NXMLeg alloc] initWithData:data[@"body"] andLegData:currLeg];
        [legs addObject:leg];
    }
    
    return [self initWithConversationId:conversationId
                           fromMemberId:data[@"from"]
                             sequenceId:[data[@"id"] integerValue]
                           creationDate:[NXMUtils dateFromISOString:data[@"timestamp"]]
                             legHistory:legs];

}

- (instancetype) initWithConversationId:(NSString *)conversationId
                           fromMemberId:(NSString *)fromMemberId
                             sequenceId:(NSInteger)sequenceId
                           creationDate:(NSDate *)date
                             legHistory:(NSMutableArray<NXMLeg *> *)legs {
    if (self = [super initWithConversationId:conversationId
                                  sequenceId:sequenceId
                                fromMemberId:fromMemberId
                                creationDate:date
                                        type:NXMEventTypeLegStatus]) {
        self.history = legs;
    }
    
    return self;
}

- (nonnull NXMLeg *)current {
    return [self.history lastObject];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> %@ history=%@ current=%@",
            NSStringFromClass([self class]),
            self,
            super.description,
            self.history,
            self.current];
}



@end
