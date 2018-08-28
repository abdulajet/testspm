//
//  NXMErrorParser.m
//  NexmoConversationObjC
//
//  Created by user on 22/03/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMErrorParser.h"

static NSDictionary<NSString *,NSNumber *> *csErrorToNXMCode;

@interface NXMErrorParser()
@end
@implementation NXMErrorParser

+(void)initialize {
    csErrorToNXMCode = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                        [NSNumber numberWithInteger:NXMStitchErrorCodeMemberNotFound],@"member:error:not-found",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeMemberAlreadyRemoved],@"conversation:error:invalid-member-state",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeEventUserNotFound],@"user:error:not-found",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeEventUserAlreadyJoined],@"conversation:error:member-already-joined",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeTokenInvalid],@"system:error:invalid-token",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeTokenExpired],@"system:error:expired-token",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeEventNotFound],@"event:error:not-found",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeConversationNotFound],@"conversation:error:not-found",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeInvalidMediaRequest],@"audio:error:invalid-event",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeMediaNotFound],@"media:error:not-found",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeMediaTooManyRequests],@"media:error:too-many-request",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeMediaBadRequest],@"media:error:bad-request",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeMediaInternalError],@"media:error:internal",
                        [NSNumber numberWithInteger:NXMStitchErrorCodeConversationInvalidMember],@"conversation:error:invalid-member",
                        nil];
}

+ (int) parseErrorWithData:(nonnull NSData*) data{
    NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self parseError:dataDict];
}

+ (int) parseError:(nonnull NSDictionary*) data{
    
    NSString* errorCodeMsg = data[@"code"];
    return csErrorToNXMCode[errorCodeMsg] ? csErrorToNXMCode[errorCodeMsg].integerValue : NXMStitchErrorCodeUnknown;
}

@end
