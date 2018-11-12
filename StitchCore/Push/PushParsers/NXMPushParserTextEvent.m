//
//  NXMPushParserTextEvent.m
//  StitchObjC
//
//  Created by Doron Biaz on 11/1/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMPushParserTextEvent.h"
#import "NXMCoreEvents.h"
#import "NXMUtils.h"
//{
//    aps =     {
//        "content-available" = 1;
//    };
//    stitch =     {
//        "application_id" = "f1a5f6fa-7d74-4b97-bdf4-4ecaae8e851e";
//        body =         {
//            text = "Sdfgf\n\nA";
//        };
//        "conversation_id" = "CON-3eed5c5f-1bfe-46b0-8fb6-642d09632244";
//        "event_type" = text;
//        from = "MEM-2708c69b-b46d-46f6-b298-622598d49e3f";
//        id = 76;
//        "message_counter" = 14;
//        "push_info" =         {
//            conversation =             {
//                "display_name" = t;
//                name = "NAM-2e2b1d82-1361-4dbf-b9a1-f13cc11c830b";
//            };
//            "from_user" =             {
//                channels =                 {
//                };
//                name = testuser2;
//                "user_id" = "USR-1628dc75-fa09-4746-9e29-681430cb6419";
//            };
//        };
//        timestamp = "2018-11-01T16:43:47.193Z";
//    };
//}

@implementation NXMPushParserTextEvent
+(nullable NSString *)eventTypeIdentifier {
    return @"text";
}
-(nullable NXMEvent *)parseStitchPushEventWithStitchPushInfo:(NSDictionary *)stitchPushInfo {
    NXMTextEvent *textEvent = [[NXMTextEvent alloc] initWithConversationId:stitchPushInfo[@"conversation_id"] sequenceId:[stitchPushInfo[@"id"] integerValue] fromMemberId:stitchPushInfo[@"from"] creationDate:[NXMUtils dateFromISOString:stitchPushInfo[@"timestamp"]] type:NXMEventTypeText];
    textEvent.text = stitchPushInfo[@"body"][@"text"];
    return textEvent;
}

@end
