//
//  NXMMemberEvent.h
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#ifndef NXMMemberEvent_h
#define NXMMemberEvent_h

#import "NXMEvent.h"
#import "NXMUser.h"
#import "NXMMediaSettings.h"

@interface NXMMemberEvent : NXMEvent
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NXMMemberState state;
@property (nonatomic, strong) NXMUser *user;
@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, strong) NXMMediaSettings *media;

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


@end

#endif /* NXMMemberEvent_h */
