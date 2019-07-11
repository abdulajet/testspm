//
//  NXMNetworkCallbacks.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/17/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXMBlocks.h"
#import "NXMConversationDetails.h"
#import "NXMPageInfo.h"
#import "NXMEvent.h"

typedef void(^NXMSuccessCallbackWithConversationDetails)(NXMConversationDetails * _Nullable conversationDetails);
typedef void(^NXMSuccessCallbackWithConversations)(NSArray<NXMConversationDetails *> * _Nullable conversationsDetails, NXMPageInfo * _Nullable pageInfo);
typedef void(^NXMSuccessCallbackWithEvents)(NSMutableArray<NXMEvent *> * _Nullable events);
typedef void(^NXMSuccessCallbackWithEvent)(NXMEvent * _Nullable event);



