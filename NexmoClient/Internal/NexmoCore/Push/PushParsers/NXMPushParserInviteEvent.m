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
#import "NXMUtils.h"

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
- (nullable NXMEvent *)parseStitchPushEventWithStitchPushInfo:(NSDictionary *)stitchPushInfo {
    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:stitchPushInfo[@"conversation_id"]
                                                                      sequenceId:[stitchPushInfo[@"id"] integerValue]
                                                                        andState:NXMMemberStateInvited
                                                                 clientRef:stitchPushInfo[@"client_ref"]
                                                                         andData:stitchPushInfo[@"body"]
                                                                    creationDate:[NXMUtils dateFromISOString:stitchPushInfo[@"timestamp"]]
                                                                        memberId:stitchPushInfo[@"from"]];
    return memberEvent;
}

+(nullable NSString *)eventTypeIdentifier {
    return @"member:invited";
}

@end
