//
//  NXMConversation.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationDetails.h"

@implementation NXMConversationDetails

- (instancetype)initWithConversationId:(NSString *)conversationId {
    if (self = [super init]) {
        self.conversationId = conversationId;
    }
    
    return  self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> conversationId=%@ sequence_number=%ld name=%@ members=%@ created=%@ properties=%@",
            NSStringFromClass([self class]),
            self,
            self.conversationId,
            (long)self.sequence_number,
            self.name,
            self.members.description,
            self.created,
            self.properties];
}



@end
