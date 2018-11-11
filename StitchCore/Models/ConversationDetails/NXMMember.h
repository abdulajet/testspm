//
//  NXMMember.h
//  StitchCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMEnums.h"

@class NXMMemberEvent;

@interface NXMMember : NSObject
@property (nonatomic, strong) NSString *conversationId;
@property (nonatomic, strong) NSString *memberId;
@property (nonatomic, strong) NSString *joinDate;
@property (nonatomic, strong) NSString *inviteDate;
@property (nonatomic, strong) NSString *leftDate;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NXMMemberState state;

- (instancetype)initWithMemberId:(NSString *)memberId conversationId:(NSString *)conversationId
                          user:(NSString *)userId name:(NSString *)name state:(NXMMemberState)state;

-(instancetype)initWithMemberEvent:(NXMMemberEvent *)memberEvent;
@end