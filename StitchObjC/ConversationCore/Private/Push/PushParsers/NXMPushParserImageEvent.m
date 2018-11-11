//
//  NXMPushParserImageEvent.m
//  StitchObjC
//
//  Created by Doron Biaz on 11/4/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMPushParserImageEvent.h"
#import "NXMConversationEvents.h"
#import "NXMUtils.h"

// image

//{
//    aps =     {
//        "content-available" = 1;
//    };
//    stitch =     {
//        "application_id" = "f1a5f6fa-7d74-4b97-bdf4-4ecaae8e851e";
//        body =         {
//            id = "074e181b-0ab7-41a0-b555-ad0e1e7d475c";
//            medium =             {
//                id = "4a65008e-6828-415b-be89-0b9a775e012f";
//                size = 138173;
//                type = MEDIUM;
//                url = "https://api.nexmo.com/v3/media/4a65008e-6828-415b-be89-0b9a775e012f";
//            };
//            original =             {
//                id = "d8add4ee-1ec3-4df8-af95-74ff9a465795";
//                size = 357767;
//                type = ORIGINAL;
//                url = "https://api.nexmo.com/v3/media/d8add4ee-1ec3-4df8-af95-74ff9a465795";
//            };
//            thumbnail =             {
//                id = "a24c4eee-7d23-4261-9623-fd8af8685999";
//                size = 61717;
//                type = THUMBNAIL;
//                url = "https://api.nexmo.com/v3/media/a24c4eee-7d23-4261-9623-fd8af8685999";
//            };
//        };
//        "conversation_id" = "CON-3eed5c5f-1bfe-46b0-8fb6-642d09632244";
//        "event_type" = image;
//        from = "MEM-2708c69b-b46d-46f6-b298-622598d49e3f";
//        id = 79;
//        "message_counter" = 15;
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
//        timestamp = "2018-11-01T16:47:09.526Z";
//    };
//}

@implementation NXMPushParserImageEvent
-(nullable NXMEvent *)parseStitchPushEventWithStitchPushInfo:(NSDictionary *)stitchPushInfo {
    NXMImageEvent *imageEvent = [[NXMImageEvent alloc] initWithConversationId:stitchPushInfo[@"conversation_id"] sequenceId:[stitchPushInfo[@"id"] integerValue] fromMemberId:stitchPushInfo[@"from"] creationDate:[NXMUtils dateFromISOString:stitchPushInfo[@"timestamp"]] type:NXMEventTypeImage];
    
    NSDictionary *body = stitchPushInfo[@"body"];
    imageEvent.imageId = body[@"id"];
    NSDictionary *originalJSON = body[@"original"];
    imageEvent.originalImage = [[NXMImageInfo alloc] initWithUuid:originalJSON[@"id"]
                                                             size:[originalJSON[@"size"] integerValue]
                                                              url:originalJSON[@"url"]
                                                             type:NXMImageTypeOriginal];
    
    NSDictionary *mediumJSON = body[@"medium"];
    imageEvent.mediumImage = [[NXMImageInfo alloc] initWithUuid:mediumJSON[@"id"]
                                                           size:[mediumJSON[@"size"] integerValue]
                                                            url:mediumJSON[@"url"]
                                                           type:NXMImageTypeMedium];
    
    
    NSDictionary *thumbnailJSON = body[@"thumbnail"];
    imageEvent.thumbnailImage = [[NXMImageInfo alloc] initWithUuid:thumbnailJSON[@"id"]
                                                              size:[thumbnailJSON[@"size"] integerValue]
                                                               url:thumbnailJSON[@"url"]
                                                              type:NXMImageTypeThumbnail];
    return imageEvent;
}

+(nullable NSString *)eventTypeIdentifier {
    return @"image";
}
@end
