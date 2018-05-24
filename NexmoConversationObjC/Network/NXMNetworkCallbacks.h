//
//  NXMNetworkCallbacks.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationDetails.h"

typedef void(^SuccessCallback)(void);
typedef void(^SuccessCallbackWithId)(NSString * _Nullable value);
typedef void(^SuccessCallbackWithConversationDetails)(NXMConversationDetails * _Nullable conversationDetails);
typedef void(^SuccessCallbackWithConversations)(NSArray<NXMConversationDetails *> * _Nullable conversationDetails);
typedef void(^SuccessCallbackWithObject)(NSObject * _Nullable object);
typedef void(^SuccessCallbackWithObjects)(NSArray * _Nullable objects);
typedef void(^ErrorCallback)(NSError * _Nullable error);
