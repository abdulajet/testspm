//
//  NXMPushParserInviteEvent.m
//  StitchObjC
//
//  Created by Doron Biaz on 11/6/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMPushParserInviteEvent.h"
#import "NXMMemberEventPrivate.h"
#import "NXMUser.h"

// invite : TODO: make sure this is the right payload
//{
//    aps =     {
//        "content-available" = 1;
//    };
//"stitch": {
//    "event_type": "member:invited",
//    "conversation_id": "CON-incoming-push",
//    "from": "my-friends-member-id",
//    "id": 2,
//    "body": {
//        "cname": "CALL_user1_user2",
//        "invited_by": "my-friends-name",
//        "user": {
//            "member_id": "MEM-sdk-test",
//            "user_id": "USR-sdk-test",
//            "name": "capi-test-sdk@nexmo.com",
//            "media": {"audio": {"earmuffed":false, "muted":false}}
//        },
//        "timestamp": {
//            "invited": "2017-11-06T12:04:12.957Z"
//        }
//    },
//    "timestamp": "2017-11-06T12:04:12.958Z"
//}
//}

@implementation NXMPushParserInviteEvent
-(nullable NXMEvent *)parseStitchPushEventWithStitchPushInfo:(NSDictionary *)stitchPushInfo {
//    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:stitchPushInfo[@"conversation_id"] sequenceId:[stitchPushInfo[@"id"] integerValue] fromMemberId:stitchPushInfo[@"from"] creationDate:[NXMUtils dateFromISOString:stitchPushInfo[@"timestamp"]] type:NXMEventTypeMember];
//
//    memberEvent.memberId = stitchPushInfo[@"from"];
//    memberEvent.user = [[NXMUser alloc] initWithId:stitchPushInfo[@"body"][@"user"][@"user_id"] name:stitchPushInfo[@"body"][@"user"][@"name"]];
//    memberEvent.state = NXMMemberStateInvited;
//    memberEvent.name = stitchPushInfo[@"body"][@"user"][@"name"];
    return [NXMPushParserInviteEvent parseMemberWithDict:stitchPushInfo];
}

+(nullable NSString *)eventTypeIdentifier {
    return @"member:invited";
}

+ (NXMMemberEvent *)parseMemberWithDict:(NSDictionary *)json {
    NXMUser *user = [[NXMUser alloc] initWithId:json[@"body"][@"user"][@"user_id"] name:json[@"body"][@"user"][@"name"]];
    NXMMediaSettings *mediaSettings = [[NXMMediaSettings alloc] initWithEnabled:(json[@"body"][@"media"] != nil ? YES : NO) suspend:NO];
    
    NSString* knockingId = json[@"body"][@"channel"][@"knocking_id"];
    
    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:json[@"conversation_id"]
                                                                            type:NXMEventTypeMember
                                                                    fromMemberId:json[@"body"][@"initiator"][@"invited"][@"member_id"]
                                                                      sequenceId:[json[@"id"] integerValue]
                                                                        memberId:json[@"from"]
                                                                            name:json[@"body"][@"user"][@"name"]
                                                                           state:NXMMemberStateInvited
                                                                            user:user
                                                                     phoneNumber:json[@"body"][@"channel"][@"to"][@"number"]
                                                                           media:mediaSettings
                                                                     channelType:json[@"body"][@"channel"][@"type"]
                                                                     channelData:json[@"body"][@"channel"][@"to"][@"number"]
                                                                      knockingId:knockingId];
    
    return memberEvent;
}
@end
