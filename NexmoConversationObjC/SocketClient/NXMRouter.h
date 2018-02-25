//
//  NXMRouter.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMMember.h"


@interface NXMRouter : NSObject

- (nullable instancetype)initWitHost:(nonnull NSString *)host;

- (void)setToken:(nonnull NSString *)token;
- (BOOL)getConversationWithId:(nonnull NSString*)id;

- (void)createConversationWithName:(nonnull NSString *)name
                     responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversationId))responseBlock;

- (void)addMemberToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock;

@end
