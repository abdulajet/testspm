//
//  NXMClient.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMClient.h"
#import "NXMStitchContext.h"
#import "NXMConversationPrivate.h"
#import "NXMCallPrivate.h"
#import "NXMCallMemberPrivate.h"
#import "NXMBlocksHelper.h"
#import "NXMLoggerInternal.h"
#import "NXMErrorsPrivate.h"
#import "NXMEventInternal.h"
#import "NXMMemberEventPrivate.h"

typedef void (^knockingComplition)(NSError * _Nullable error, NXMCall * _Nullable call);
NSString *const NXMCallPrefix = @"CALL_";


@interface NXMKnockingObj : NSObject
@property knockingComplition complition;
@property id<NXMCallDelegate> delegate;
@end
@implementation NXMKnockingObj
@end

@interface NXMClient() <NXMStitchContextDelegate>
@property (nonatomic, nonnull) NXMStitchContext *stitchContext;
@property (nonatomic, nullable, weak) id <NXMClientDelegate> delegate;
@property (nonatomic, nonnull) NSMutableDictionary<NSString*, NXMKnockingObj*> * knockingIdsToCompletion;

@end

@implementation NXMClient

- (instancetype)init {
    LOG_DEBUG("--------------------- Nexmo Client-----------------------");
    LOG_DEBUG("::::    :::  ::::::::::  :::    :::  ::::    ::::    ::::::::");
    LOG_DEBUG(":+:+:   :+:  :+:         :+:    :+:  +:+:+: :+:+:+  :+:    :+:");
    LOG_DEBUG(":+:+:+  +:+  +:+          +:+  +:+   +:+ +:+:+ +:+  +:+    +:+");
    LOG_DEBUG("+#+ +:+ +#+  +#++:++#      +#++:+    +#+  +:+  +#+  +#+    +:+");
    LOG_DEBUG("+#+  +#+#+#  +#+          +#+  +#+   +#+       +#+  +#+    +#+");
    LOG_DEBUG("#+#   #+#+#  #+#         #+#    #+#  #+#       #+#  #+#    #+#");
    LOG_DEBUG("###    ####  ##########  ###    ###  ###       ###   ########");
    LOG_DEBUG("--------------------- Nexmo Client-----------------------");
    
    if(self = [super init]) {
        self.stitchContext = [[NXMStitchContext alloc] initWithCoreClient:[[NXMCore alloc] initWithToken:@""]];
        [self.stitchContext setDelegate:self];
         
        [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(onMemberEvent:) name:kNXMEventsDispatcherNotificationMember object:nil];
        self.knockingIdsToCompletion = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [self.stitchContext.eventsDispatcher.notificationCenter removeObserver:self];
}

#pragma shared

+ (NXMClient *)shared {
    static NXMClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NXMClient new];
    });
    
    return sharedInstance;
}

#pragma mark - login and connectivity

-(bool) isConnected {
    return [self getConnectionStatus] == NXMConnectionStatusConnected;
}

-(NXMConnectionStatus)getConnectionStatus {
    return self.stitchContext.coreClient.connectionStatus;
}

// TODO: move to user defaults
-(NXMUser *)getUser {
    return [self.stitchContext currentUser];
}

// TODO: move to user defaults
-(NSString *)getToken {
    return self.stitchContext.coreClient.token;
}

-(void)loginWithAuthToken:(NSString *)authToken {
    LOG_DEBUG("" );
    if(!self.delegate) {
        LOG_ERROR("login called without setting delegate");
    }
    self.stitchContext.coreClient.token = authToken;
    [self.stitchContext.coreClient login];

}

-(void)updateAuthToken:(nonnull NSString *)authToken {
    LOG_DEBUG([authToken UTF8String]);

    [self.stitchContext.coreClient refreshAuthToken:authToken];
}

-(void)logout {
    LOG_DEBUG("" );

    if (self.connectionStatus == NXMConnectionStatusDisconnected) {
        return;
    }
    
    //TODO: disableAudio
    
    //TODO: decide if disable should be required before logout, or maybe it should be
    [self disablePushNotifications:^(NSError * _Nullable error) {
        if(error) {
            LOG_ERROR("failed disabling push during logout with error: %s", [error.description UTF8String]);
            return;
        }
    }];
    
    [self.stitchContext.coreClient logout];
}

- (void)connectionStatusChanged:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    LOG_DEBUG("status %ld reason %ld", status, reason);
    NSError *setUpCleanUpError = nil;
    switch (self.connectionStatus) {
        case NXMConnectionStatusDisconnected:
            if(![self cleanUpWithErrorPtr:&setUpCleanUpError]) {
                //TODO: report/fail cleanup error
            }
            break;
        case NXMConnectionStatusConnected:
            if(![self setUpWithErrorPtr:&setUpCleanUpError]) {
                //TODO: report/fail setup error
            }
            break;
        case NXMConnectionStatusConnecting:
        default:
            break;
    }
    
    [self.delegate client:self didChangeConnectionStatus:status reason:reason];
}

#pragma mark - conversation

-(void)getConversationWithUUid:(nonnull NSString *)converesationId
                  completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion {
    LOG_DEBUG([converesationId UTF8String]);
    if (![self isConnected]){
        LOG_DEBUG("SDK disconnected" );
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completion(resError, nil);
        return;
    }
    
    [self.stitchContext.coreClient getConversationDetails:converesationId
                                                onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
                                                    if(completion) {
                                                        NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContext];
                                                        completion(nil, conversation);
                                                    }
                                                }
                                                  onError:^(NSError * _Nullable error) {
                                                      [NXMBlocksHelper runWithError:error value:nil completion:completion];
                                                  }];
    }

-(void)createConversationWithName:(nonnull NSString *)name completionHandler:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion {
    LOG_DEBUG("" );

    if (![self isConnected]){
        LOG_DEBUG("SDK disconnected" );
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completion(resError, nil);
        return;
    }
    __weak NXMClient *weakSelf = self;
    [self.stitchContext.coreClient createConversationWithName:name
                                                    onSuccess:^(NSString * _Nullable value) {
                                                        if(completion) {
                                                            [weakSelf getConversationWithUUid:value completionHandler:^(NSError * _Nullable error, NXMConversation * _Nullable conversation){
                                                                if(!conversation) {
                                                                    NSError *wrappingError = [NXMErrors nxmErrorWithErrorCode:NXMErrorCodeConversationRetrievalFailed andUserInfo:@{NSUnderlyingErrorKey: error}];
                                                                    
                                                                    [NXMBlocksHelper runWithError:wrappingError value:nil completion:completion];
                                                                    return;
                                                                }
                                                                
                                                                [NXMBlocksHelper runWithError:nil value:conversation completion:completion];
                                                            }];
                                                        }
                                                    }
                                                    onError:^(NSError * _Nullable error) {
                                                        [NXMBlocksHelper runWithError:error value:nil completion:completion];

                                                    }];
}

- (void) addPendingKnockingId:(nonnull NSString*)knockingId
                     delegate:(id<NXMCallDelegate>)delegate
                   completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion{
    LOG_DEBUG([knockingId UTF8String]);

    NXMKnockingObj *knockingObj = [NXMKnockingObj new];
    knockingObj.complition = completion;
    knockingObj.delegate = delegate;
    self.knockingIdsToCompletion[knockingId] = knockingObj;
}

- (void)startIpCall:(nonnull NSString *)user
            delegate:(id<NXMCallDelegate>)delegate
          completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion {
    LOG_DEBUG([user UTF8String]);
    __weak NXMClient *weakSelf = self;
    __weak NXMCore *weakCore = self.stitchContext.coreClient;
    [weakCore createConversationWithName:[NSString stringWithFormat:@"%@%@", NXMCallPrefix, [[NSUUID UUID] UUIDString]]
                               onSuccess:^(NSString * _Nullable convId) {
                                   [weakSelf getConversationWithUUid:convId completionHandler:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
                                       if (conversation){
                                           [conversation join:^(NSError * _Nullable error, NXMMember * _Nullable member) {
                                               if (member) {
                                                   [conversation inviteMemberWithUsername:user withMedia:YES completion:^(NSError *error, NXMMember *member) {
                                                       
                                                       if (error) {
                                                           [NXMBlocksHelper runWithError:error
                                                                                   value:nil
                                                                              completion:completion];
                                                           return;
                                                       }
                                                       
                                                       NXMCall * call = [[NXMCall alloc] initWithConversation:conversation];

                                                       [NXMBlocksHelper runWithError:nil value:call completion:completion];
                                                   }];
                                               }
                                           }];
                                       } else {
                                           [NXMBlocksHelper runWithError:[NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown andUserInfo:nil]
                                                        value:nil
                                                   completion:completion];

                                       }
                                   }];
                               }
                                 onError:^(NSError * _Nullable error) {
                                     [NXMBlocksHelper runWithError:error value:nil completion:completion];
                                 }
     ];
}

- (void)startServerCall:(nonnull NSString *)callee
            delegate:(id<NXMCallDelegate>)delegate
          completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion {
    LOG_DEBUG([callee UTF8String]);

    __weak NXMClient *weakSelf = self;
    __weak NXMCore *weakCore = self.stitchContext.coreClient;
    [weakCore inviteToConversation:weakSelf.user.name withPhoneNumber:callee onSuccess:^(NSString * _Nullable value) {
        if (value)
            [weakSelf addPendingKnockingId:value delegate:delegate completion:completion];
    } onError:^(NSError * _Nullable error) {
        LOG_ERROR("startServerCall falied %s", [error.description UTF8String]);
    }];
}

- (void)call:(nonnull NSString *)callees
           callHandler:(NXMCallHandler)callHandler
         completionHandler:(void (^ _Nullable)(NSError * _Nullable, NXMCall * _Nullable))completionHandler {
    LOG_DEBUG([[callees description] UTF8String]);
    if (![self isConnected]){
        LOG_DEBUG("SDK disconnected" );
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completionHandler(resError, nil);
        return;
    }
    switch (callHandler) {
        case NXMCallHandlerInApp:
            [self startIpCall:callees delegate:nil completion:completionHandler];
            break;
        case NXMCallHandlerServer:
            [self startServerCall:callees delegate:nil completion:completionHandler];
            break;
        default:
            break;
    }
}

#pragma mark - push

- (void)enablePushNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
                                     isPushKit:(BOOL)isPushKit
                                     isSandbox:(BOOL)isSandbox
                                    completionHandler:(void (^ _Nullable)(NSError * _Nullable))completionHandler {
    LOG_DEBUG("%s %d %d", [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding], isPushKit, isSandbox);
    if (![self isConnected]){
        LOG_DEBUG("SDK disconnected" );
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completionHandler(resError);
        return;
    }
    [self.stitchContext.coreClient enablePushNotificationsWithDeviceToken:deviceToken isSandbox:isSandbox isPushKit:isPushKit onSuccess:^{
        LOG_DEBUG("Nexmo push notifications enabled" );
        [NXMBlocksHelper runWithError:nil completion:completionHandler];
    } onError:^(NSError * _Nullable error) {
        LOG_ERROR("Nexmo push notifications enabling failed with error: %s", [error.description UTF8String]);
        [NXMBlocksHelper runWithError:error completion:completionHandler];
    }];
}

- (void)disablePushNotifications:(void(^_Nullable)(NSError * _Nullable error))completionHandler {
    LOG_DEBUG("" );

    if (![self isConnected]){
        LOG_DEBUG("SDK disconnected" );
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completionHandler(resError);
        return;
    }
    [self.stitchContext.coreClient disablePushNotificationsWithOnSuccess:^{
        LOG_DEBUG("Nexmo push notifications disabled" );
        [NXMBlocksHelper runWithError:nil completion:completionHandler];
    } onError:^(NSError * _Nullable error) {
        LOG_ERROR("Nexmo push notifications disabling failed with error: %s", [error.description UTF8String]);
        [NXMBlocksHelper runWithError:error completion:completionHandler];
    }];

}

- (BOOL)isNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo {
    LOG_DEBUG([[userInfo description] UTF8String]);
    
    return [self.stitchContext.coreClient isNexmoPushWithUserInfo:userInfo];
    
}

- (void)processNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo completionHandler:(void (^ _Nullable)(NSError * _Nullable))completionHandler {
    LOG_DEBUG([[userInfo description] UTF8String]);
    
    if (![self isConnected]){
        LOG_DEBUG("SDK disconnected");
        completionHandler([[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil]);
        return;
    }
    
    [self.stitchContext.coreClient processNexmoPushWithUserInfo:userInfo onSuccess:^(NXMEvent * _Nullable event) {
        [NXMBlocksHelper runWithError:nil completion:completionHandler];
    } onError:^(NSError * _Nullable error) {
        LOG_ERROR("Error processing nexmo push with error:%s", [error.description UTF8String]);
        [NXMBlocksHelper runWithError:error completion:completionHandler];
    }];
}


#pragma mark - notification center

- (void)onMemberEvent:(NSNotification* )notification {
    LOG_DEBUG([notification.name UTF8String]);
    NXMMemberEvent* event = [NXMEventsDispatcherNotificationHelper<NXMMemberEvent *> nxmNotificationModelWithNotification:notification];
    
    LOG_DEBUG([[event description] UTF8String]);
    
    if (![event.user.uuid isEqualToString:self.user.uuid]) { return; }
    /*
     Three types of events
     1. incoming conversation (Joined + Someone else invite you + no knocking id)
     2. incoming IP call (Invited + media enabled)
     3. out going server call (Joined + knocking Id exist)
    */
    //Incoming conversation
    if (![event.fromMemberId isEqualToString:event.memberId] &&
        event.state != NXMMemberStateLeft  &&
        !event.knockingId &&
        !event.media.isEnabled) {
        if ([self.delegate respondsToSelector:@selector(client:didReceiveCall:)]) {
            LOG_DEBUG("got newConversation event" );
            
            [self getConversationWithUUid:event.conversationUuid completionHandler:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
                if (error) {
                    LOG_ERROR("get conversation failed %s", [error.description UTF8String]);
                    return;
                }
                
                if (!conversation) {
                    LOG_ERROR("got empty conversation without error conversation id %s:", [event.conversationUuid UTF8String]);
                }
                
                
                [self.delegate client:self didReceiveConversation:conversation];
            }];
        }
        
        return;
    }
    
    //Incoming IP call
    if (event.state == NXMMemberStateInvited && event.media.isEnabled) {
        if ([self.delegate respondsToSelector:@selector(client:didReceiveCall:)]) { // optimization
            
            LOG_DEBUG("got member invited event with enable media" );
            
            [self getConversationWithUUid:event.conversationUuid completionHandler:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
                if (error) {
                    LOG_ERROR("get conversation failed %s", [error.description UTF8String]);
                    return;
                }

                if (!conversation){
                    LOG_ERROR("got empty conversation without error conversation id %s:", [event.conversationUuid UTF8String]);
                }

                if (![conversation.displayName hasPrefix:NXMCallPrefix] && // IP-IP CS
                        event.fromMemberId) { // IP-IP VAPI
                    LOG_ERROR("member invited event with media enabled without call perfix" );
                    return;
                }

                NXMCall * call = [[NXMCall alloc] initWithConversation:conversation];
                [self.delegate client:self didReceiveCall:call];

            }];

        }
    }
    //Out going server call
    if (event.state == NXMMemberStateJoined && event.knockingId){
        LOG_DEBUG("got member JOINED event with knockingId" );
        
        [self getConversationWithUUid:event.conversationUuid completionHandler:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
            if (error) {
                 LOG_ERROR("got empty conversation without error conversation id %s:", [event.conversationUuid UTF8String]);
                return;
            }
            
            if (!conversation){
                LOG_ERROR("got empty conversation without error conversation id %s:", [event.conversationUuid UTF8String]);
            }
            
            if (event.knockingId && self.knockingIdsToCompletion[event.knockingId]){
                LOG_DEBUG("processing knockingId");
                NXMKnockingObj *obj = self.knockingIdsToCompletion[event.knockingId];
                [conversation enableMedia];
                [self.knockingIdsToCompletion removeObjectForKey:event.knockingId];
                
                NXMCall * call = [[NXMCall alloc] initWithConversation:conversation];
                obj.complition(nil, call);
            } else {
                LOG_ERROR("got member event with knockingId that client doesn't have");
                //TODO: check if this is a valid state for a call
                //this could happened if we get the member events before cs return the knocking id
                //to prevent drop calls we use the Incoming IP call
              //  [self.delegate didReceiveCall:call];
            }
        }];
    }
}

#pragma mark - private

- (BOOL)setUpWithErrorPtr:(NSError **)errorPtr {
    LOG_DEBUG("" );
    //TODO: set up, set error and return false if problematic
    return YES;
}

- (BOOL)cleanUpWithErrorPtr:(NSError **)errorPtr {
    LOG_DEBUG("" );
    //TODO: clean up, set error and return false if problematic
    return YES;
}

@end
