//
//  NXMConversationsPagePrivate.h
//  NexmoClient
//
//  Created by Nicola Di Pol on 12/11/2019.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationsPage.h"
#import "NXMConversationIdsPage.h"
#import "NXMPageResponse.h"

@protocol NXMConversationsPageProxy<NSObject>

- (void)getConversationsPageWithSize:(NSInteger)size
                               order:(NXMPageOrder)order
                              userId:(nonnull NSString *)userId
                   completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversationsPage * _Nullable page))completionHandler;

- (void)getConversationsPageForURL:(nonnull NSURL *)url
                 completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversationsPage * _Nullable page))completionHandler;

@end

@interface NXMConversationsPage (Private)

@property (nonatomic, nonnull, readonly) NXMPageResponse *pageResponse;
@property (nonatomic, nonnull, readonly) id<NXMConversationsPageProxy> proxy;

- (nonnull instancetype)initWithSize:(NSUInteger)size
                               order:(NXMPageOrder)order
                        pageResponse:(nonnull NXMPageResponse *)pageResponse
                    conversationsPagingProxy:(nonnull id<NXMConversationsPageProxy>)proxy
                               conversations:(nonnull NSArray<NXMConversation *> *)conversations;

@end
