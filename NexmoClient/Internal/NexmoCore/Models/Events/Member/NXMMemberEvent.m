//
//  NXMMemberEvent.m
//  NexmoConversationObjC
//
//  Created by user on 21/03/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMMemberEvent.h"
#import "NXMCoreEventsPrivate.h"

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
    return [self initWithConversationId:conversationId type:type fromMemberId:fromMemberId sequenceId:sequenceId memberId:memberId name:name state:state user:user phoneNumber:nil media:media];
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
    return [self initWithConversationId:conversationId type:type fromMemberId:fromMemberId sequenceId:sequenceId memberId:memberId name:name state:state user:user phoneNumber:phoneNumber media:media channelType:@"" channelData:nil];
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
                                 media:(NXMMediaSettings *)media
                           channelType:(NSString *)channelType
                           channelData:(NSString *)channelData{
    return [self initWithConversationId:conversationId type:type fromMemberId:fromMemberId sequenceId:sequenceId memberId:memberId name:name state:state user:user phoneNumber:phoneNumber media:media channelType:channelType channelData:channelData knockingId:nil];
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
                                 media:(NXMMediaSettings *)media
                           channelType:(NSString *)channelType
                           channelData:(NSString *)channelData
                            knockingId:(NSString *)knockingId{
    if (self = [super initWithConversationId:conversationId sequenceId:sequenceId fromMemberId:fromMemberId creationDate:nil type:type]) {
        self.type = type;
        self.memberId = memberId;
        self.state = state;
        self.user = user;
        self.phoneNumber = phoneNumber;
        self.media = media;
        self.channelType = [NXMMemberEvent getTypeFromString:channelData];;
        self.channelData = channelData;
        self.knockingId = knockingId;
    }
    
    return self;
}

+ (NXMChannelType)getTypeFromString:(nullable NSString *)typeString{
    
    return [typeString isEqualToString:@"app"] ? NXMChannelTypeApp :
            [typeString isEqualToString:@"phone"] ? NXMChannelTypePhone :
            NXMChannelTypeUnknown;
}

@end
