//
//  NXMMuteAudioRequest.h
//  StitchObjC
//
//  Created by Doron Biaz on 8/27/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMBaseRequest.h"
#import "NXMEnums.h"

@interface NXMSuspendResumeMediaRequest : NXMBaseRequest
@property (nonatomic) NXMMediaType mediaType;
@property (nonatomic, strong, nonnull) NSString *conversationId;
@property (nonatomic, strong, nonnull) NSString *fromMemberId;
@property (nonatomic, strong, nonnull) NSString *toMemberId;
@property (nonatomic, strong, nullable) NSString *rtcId;


- (instancetype)initWithConversationId:(nonnull NSString *)conversationId fromMemberId:(nonnull NSString *)fromMemberId toMemberId:(nonnull NSString *)toMemberId rtcId:(nullable NSString *)rtcId mediaType:(NXMMediaType)mediaType;
@end
