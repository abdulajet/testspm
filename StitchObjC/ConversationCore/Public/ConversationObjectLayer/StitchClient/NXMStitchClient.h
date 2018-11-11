//
//  NXMStitch.h
//  StitchObjC
//
//  Created by Doron Biaz on 9/6/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMEventsDispatcher.h"
#import "NXMStitchClientDelegate.h"
#import "NXMStitchContextDelegate.h"
#import "NXMConversation.h"

@interface NXMStitchClient : NSObject<NXMStitchContextDelegate>
@property (readonly, nonatomic) BOOL isLoggedIn;
@property (readonly, nonatomic) BOOL isConnected;

+(NXMStitchClient *)sharedInstance;

-(void)setDelegate:(nonnull NSObject<NXMStitchClientDelegate> *)delegate;

-(void)loginWithAuthToken:(nonnull NSString *)authToken;
-(void)updateAuthToken:(nonnull NSString *)authToken;
-(void)logout;

-(nullable NXMUser *)getUser;
-(nullable NSString *)getToken;

-(void)getConversationWithId:(nonnull NSString *)converesationId completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion;
-(void)createConversationWithName:(nonnull NSString *)name completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion;
@end
