//
//  NXMConversationCoreCallbacks.h
//  Stitch_iOS
//
//  Created by Doron Biaz on 11/5/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationDetails.h"
#import "NXMPageInfo.h"
#import "NXMEvent.h"

typedef void(^NXMCoreSuccessCallback)(void);
typedef void(^NXMCoreSuccessCallbackWithId)(NSString * _Nullable value);
typedef void(^NXMCoreSuccessCallbackWithConversationDetails)(NXMConversationDetails * _Nullable conversationDetails);
typedef void(^NXMCoreSuccessCallbackWithConversations)(NSArray<NXMConversationDetails *> * _Nullable conversationsDetails, NXMPageInfo * _Nullable pageInfo);
typedef void(^NXMCoreSuccessCallbackWithEvent)(NXMEvent * _Nullable event);
typedef void(^NXMCoreSuccessCallbackWithEvents)(NSMutableArray<NXMEvent *> * _Nullable events);
typedef void(^NXMCoreSuccessCallbackWithObject)(NSObject * _Nullable object);
typedef void(^NXMCoreSuccessCallbackWithObjects)(NSArray * _Nullable objects);
typedef void(^NXMCoreErrorCallback)(NSError * _Nullable error);
