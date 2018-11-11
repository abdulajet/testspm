//
//  NXMMemberEvent.m
//  NexmoConversationObjC
//
//  Created by user on 21/03/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMemberEvent.h"

@implementation NXMMemberEvent

- (instancetype)initWithConversationId:(NSString *)conversationId
                         type:(NXMEventType)type
                 fromMemberId:(NSString *)fromMemberId
                   sequenceId:(NSInteger)sequenceId
                     memberId:(NSString *)memberId
                         name:(NSString *)name
                        state:(NXMMemberState)state
                         user:(NXMUser *)user
                        media:(NXMMediaSettings *)media {
    return [self initWithConversationId:conversationId type:type fromMemberId:fromMemberId sequenceId:sequenceId memberId:memberId name:name state:state user:user phoneNumber:NULL media:media];
}

- (instancetype)initWithConversationId:(NSString *)conversationId
                         type:(NXMEventType)type
                 fromMemberId:(NSString *)fromMemberId
                   sequenceId:(NSInteger)sequenceId
                     memberId:(NSString *)memberId
                         name:(NSString *)name
                        state:(NXMMemberState)state
                         user:(NXMUser *)user
                  phoneNumber:(NSString *)phoneNumber
                        media:(NXMMediaSettings *)media {
    if (self = [super initWithConversationId:conversationId sequenceId:sequenceId fromMemberId:fromMemberId creationDate:NULL type:type]) {
        self.type = type;
        self.memberId = memberId;
        self.name = name;
        self.state = state;
        self.user = user;
        self.phoneNumber = phoneNumber;
        self.media = media;
    }
    
    return self;
}


@end
