//
//  NXMErrorParser.m
//  NexmoConversationObjC
//
//  Created by user on 22/03/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMErrorParser.h"
@interface NXMErrorParser()
@end
@implementation NXMErrorParser

+ (int) parseError:(nonnull NSData*) data{
    
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSString* errorCodeMsg = json[@"code"];
    if ([errorCodeMsg isEqualToString:@"member:error:not-found"]){
        return NXMStitchErrorCodeMemberNotFound;
    }
    else if ([errorCodeMsg isEqualToString:@"conversation:error:invalid-member-state"]){
        return NXMStitchErrorCodeMemberAlreadyRemoved;
    }
    else if ([errorCodeMsg isEqualToString:@"user:error:not-found"]){
        return NXMStitchErrorCodeEventUserNotFound;
    }
    else if ([errorCodeMsg isEqualToString:@"conversation:error:member-already-joined"]){
        return NXMStitchErrorCodeEventUserAlreadyJoined;
    }
    else if ([errorCodeMsg isEqualToString:@"system:error:invalid-token"]){
        return NXMStitchErrorCodeTokenInvalid;
    }
    else if ([errorCodeMsg isEqualToString:@"system:error:expired-token"]){
        return NXMStitchErrorCodeTokenExpired;
    }
    return NXMStitchErrorCodeUnknown;
}

+ (NSString*) toString:(int) errorResult{
    NSString *str = [NSString alloc];
    str = @"";
    switch (errorResult) {
        case NXMStitchErrorCodeUnknown:
            str = @"Nexmo Stitch error code unknown";
            break;
        case NXMStitchErrorCodeSessionUnknown:
            str = @"Nexmo Stitch error code session unknown";
            break;
        case NXMStitchErrorCodeSessionInvalid:
            str = @"Nexmo Stitch error code session invalid";
            break;
        case NXMStitchErrorCodeTokenUnknown:
            str = @"Nexmo Stitch error code Token unknown";
            break;
        case NXMStitchErrorCodeTokenInvalid:
            str = @"Nexmo Stitch error code tokne invalid";
            break;
        case NXMStitchErrorCodeTokenExpired:
            str = @"Nexmo Stitch error code token expired";
            break;
        case NXMStitchErrorCodeMemberUnknown:
            str = @"Nexmo Stitch error code member unknown";
            break;
        case NXMStitchErrorCodeMemberNotFound:
            str = @"Nexmo Stitch error code member not found";
            break;
        case NXMStitchErrorCodeMemberAlreadyRemoved:
            str = @"Nexmo Stitch error code member already removed";
            break;
        case NXMStitchErrorCodeEventUnknown:
            str = @"Nexmo Stitch error code event unknown";
            break;
        case NXMStitchErrorCodeEventUserNotFound:
            str = @"Nexmo Stitch error code event user not found";
            break;
        case NXMStitchErrorCodeEventUserAlreadyJoined:
            str = @"Nexmo Stitch error code event user already joined";
            break;
        case NXMStitchErrorCodeEventInvalid:
            str = @"Nexmo Stitch error code event invalid";
            break;
        case NXMStitchErrorCodeEventBadPermission:
            str = @"Nexmo Stitch error code event bad permission";
            break;
        case NXMStitchErrorCodeConversationUnknown:
            str = @"Nexmo Stitch error code conversation unknown";
            break;
        case NXMStitchErrorCodeConversationNotFound:
            str = @"Nexmo Stitch error code conversation not found";
            break;
            
        default:
            break;
    }
    return str;
}

@end
