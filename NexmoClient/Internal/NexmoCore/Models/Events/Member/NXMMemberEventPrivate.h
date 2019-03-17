//
//  NXMMemberEventPrivate.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//


#import "NXMMemberEvent.h"

@interface NXMMemberEvent (private)

- (instancetype)initWithConversationId:(NSString *)conversationId
    type:(NXMEventType)type
    fromMemberId:(NSString *)fromMemberId
    sequenceId:(NSInteger)sequenceId
    memberId:(NSString *)memberId
    name:(NSString *)name
    state:(NXMMemberState)state
    user:(NXMUser *)user
    media:(NXMMediaSettings *)isMediaEnabled;

- (instancetype)initWithConversationId:(NSString *)conversationId
    type:(NXMEventType)type
    fromMemberId:(NSString *)fromMemberId
    sequenceId:(NSInteger)sequenceId
    memberId:(NSString *)memberId
    name:(NSString *)name
    state:(NXMMemberState)state
    user:(NXMUser *)user
    phoneNumber:(NSString *)phoneNumber
    media:(NXMMediaSettings *)isMediaEnabled;

//- (instancetype)initWithConversationId:(NSString *)conversationId
//    type:(NXMEventType)type
//    fromMemberId:(NSString *)fromMemberId
//    sequenceId:(NSInteger)sequenceId
//    memberId:(NSString *)memberId
//    name:(NSString *)name
//    state:(NXMMemberState)state
//    user:(NXMUser *)user
//    phoneNumber:(NSString *)phoneNumber
//    media:(NXMMediaSettings *)media
//    channelType:(NXMChannelType)channelType
//    channelData:(NSString*)channelData;

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
                            knockingId:(NSString *)knockingId;

+ (NXMChannelType)getTypeFromString:(nullable NSString*)typeString;

@end

