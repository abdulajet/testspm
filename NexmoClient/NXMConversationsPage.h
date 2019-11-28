//
//  NXMConversationsPage.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMConversation.h"

@interface NXMConversationsPage : NSObject

/*!
 * @brief Conversations page size. Size could be greater than conversations array's size.
 * @code NXMPageOrder order = myNXMConversationsPage.size;
 */
@property (nonatomic, assign, readonly) NSUInteger size;

/*!
 * @brief Conversations date order in the page.
 * @code NXMPageOrder order = myNXMConversationsPage.order;
 */
@property (nonatomic, assign, readonly) NXMPageOrder order;

/*!
 * @brief Conversations contained in the page. The array size could be smaller than the page size.
 * @code NSArray<NXMConversation *> *conversations = myNXMConversationsPage.conversations;
 */
@property (nonatomic, nonnull, readonly) NSArray<NXMConversation *> *conversations;

/*!
 * @brief Checks if there's a next page.
 * @code BOOL hasNextPage = [myNXMConversationsPage hasNextPage];
 */
- (BOOL)hasNextPage;

/*!
 * @brief Checks if there's a previous page.
 * @code BOOL hasPreviousPage = [myNXMConversationsPage hasPreviousPage];
 */
- (BOOL)hasPreviousPage;

/*!
 * @brief Retrieves the next page. If the current page is the last, completionHandler will be called with an error.
 * @code [myNXMConversationsPage nextPage:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
     // ... use page...
 }];
 */
- (void)nextPage:(void(^_Nullable)(NSError * _Nullable error, NXMConversationsPage * _Nullable page))completionHandler;

/*!
 * @brief Retrieves the previous page. If the current page is the first, completionHandler will be called with an error.
 * @code [myNXMConversationsPage previousPage:^(NSError * _Nullable error, NXMConversationsPage * _Nullable page) {
 // ... use page...
 }];
 */
- (void)previousPage:(void(^_Nullable)(NSError * _Nullable error, NXMConversationsPage * _Nullable page))completionHandler;

@end
