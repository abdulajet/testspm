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
#import "NXMLogger.h"
#import "NXMErrorsPrivate.h"


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

- (instancetype)initWithToken:(NSString *)authToken {
    [NXMLogger debugWithFormat:@"authToken %@",authToken];
    if(self = [super init]) {
        self.stitchContext = [[NXMStitchContext alloc] initWithCoreClient:[[NXMCore alloc] initWithToken:authToken]];
        [self.stitchContext setDelegate:self];
         
        [self.stitchContext.eventsDispatcher.notificationCenter addObserver:self selector:@selector(onMemberEvent:) name:kNXMEventsDispatcherNotificationMember object:nil];
        self.knockingIdsToCompletion = [[NSMutableDictionary alloc] init];
    }
    
    [NXMLogger debug:@""];
    return self;
}

- (void)dealloc {
    [self.stitchContext.eventsDispatcher.notificationCenter removeObserver:self];
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
    return self.stitchContext.coreClient.user;
}

// TODO: move to user defaults
-(NSString *)getToken {
    return self.stitchContext.coreClient.token;
}

-(void)login {
    [NXMLogger debug:@"entry"];
    if(!self.delegate) {
        [NXMLogger error:@"NXMClient: login called without setting delegate"];
    }
    [self.stitchContext.coreClient login];
    [NXMLogger debug:@"exit"];

}

-(void)refreshAuthToken:(nonnull NSString *)authToken {
    [NXMLogger debug:@"entry"];
    [self.stitchContext.coreClient refreshAuthToken:authToken];
    [NXMLogger debug:@"exit"];
}

-(void)logout {
    [NXMLogger debug:@"entry"];
    if (self.connectionStatus == NXMConnectionStatusDisconnected) {
        return;
    }
    
    //TODO: disableAudio
    
    //TODO: decide if disable should be required before logout, or maybe it should be
    [self disablePushNotificationsWithCompletion:^(NSError * _Nullable error) {
        if(error) {
            [NXMLogger errorWithFormat:@"NXMClient: failed disabling push during logout with error: %@", error];
            return;
        }
    }];
    
    [self.stitchContext.coreClient logout];
    [NXMLogger debug:@"exit"];
}

- (void)connectionStatusChanged:(NXMConnectionStatus)status reason:(NXMConnectionStatusReason)reason {
    [NXMLogger debugWithFormat:@"%ld %ld entry", status, reason];
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
    
    [self.delegate connectionStatusChanged:status reason:reason];
    [NXMLogger debug:@"exit"];
}

#pragma mark - conversation

-(void)getConversationWithId:(nonnull NSString *)converesationId
                  completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion {
    [NXMLogger debugWithFormat:@"%@ entry", converesationId];
    if (![self isConnected]){
        [NXMLogger info:@"NXMClient:getConversationWithId:SDK disconnected"];
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
    
    [NXMLogger debug:@"exit"];
}

-(void)createConversationWithName:(nonnull NSString *)name completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion {
    [NXMLogger debugWithFormat:@"%@ entry", name];
    if (![self isConnected]){
        [NXMLogger info:@"NXMClient:createConversationWithName:SDK disconnected"];
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completion(resError, nil);
        return;
    }
    __weak NXMClient *weakSelf = self;
    [self.stitchContext.coreClient createConversationWithName:name
                                                    onSuccess:^(NSString * _Nullable value) {
                                                        if(completion) {
                                                            [weakSelf getConversationWithId:value completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation){
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
    [NXMLogger debug:@"exit"];

}

- (void) addPendingKnockingId:(nonnull NSString*)knockingId
                     delegate:(id<NXMCallDelegate>)delegate
                   completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion{
    [NXMLogger debugWithFormat:@"%@ entry", knockingId];
    NXMKnockingObj *knockingObj = [NXMKnockingObj new];
    knockingObj.complition = completion;
    knockingObj.delegate = delegate;
    self.knockingIdsToCompletion[knockingId] = knockingObj;
}

- (void) startIpCall:(nonnull NSArray<NSString *>*)users
            delegate:(id<NXMCallDelegate>)delegate
          completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion {
    [NXMLogger debugWithFormat:@"%@ entry", [users description]];
    __weak NXMClient *weakSelf = self;
    __weak NXMCore *weakCore = self.stitchContext.coreClient;
    [weakCore createConversationWithName:[NSString stringWithFormat:@"%@%@", NXMCallPrefix, [[NSUUID UUID] UUIDString]]
                               onSuccess:^(NSString * _Nullable convId) {
                                   [weakSelf getConversationWithId:convId completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
                                       if (conversation){
                                           [conversation joinWithCompletion:^(NSError * _Nullable error, NXMMember * _Nullable member) {
                                               if (member){
                                                   NXMCall * call = [[NXMCall alloc] initWithConversation:conversation];
                                                   [call dialWithMember:member];
                                                   
                                                   for (NSString *username in users) {
                                                       [call addCallMemberWithUsername:username completionHandler:nil];
                                                   }
                                                   
                                                   [call setDelegate:delegate];
                                                   
                                                   [NXMBlocksHelper runWithError:nil value:call completion:completion];
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
    [NXMLogger debug:@"exit"];

}

- (void) startServerCall:(nonnull NSArray<NSString *>*)users
            delegate:(id<NXMCallDelegate>)delegate
          completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion {
    [NXMLogger debugWithFormat:@"%@ entry", [users description]];
    __weak NXMClient *weakSelf = self;
    __weak NXMCore *weakCore = self.stitchContext.coreClient;
    [weakCore inviteToConversation:weakSelf.user.name withPhoneNumber:users[0] onSuccess:^(NSString * _Nullable value) {
        if (value)
            [weakSelf addPendingKnockingId:value delegate:delegate completion:completion];
    } onError:^(NSError * _Nullable error) {
        [NXMLogger debugWithFormat:@"startServerCall falied %@", error.description];
    }];
    [NXMLogger debug:@"exit"];
}

- (void)call:(nonnull NSArray<NSString *>*)callees
           callHandler:(NXMCallHandler)callHandler
           delegate:(id<NXMCallDelegate>)delegate
         completion:(void(^_Nullable)(NSError * _Nullable error, NXMCall * _Nullable call))completion {
    [NXMLogger debugWithFormat:@"%@ %ld entry", [callees description], callHandler];
    if (![self isConnected]){
        [NXMLogger info:@"NXMClient:call:SDK disconnected"];
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completion(resError, nil);
        return;
    }
    switch (callHandler) {
        case NXMCallHandlerInApp:
            [self startIpCall:callees delegate:delegate completion:completion];
            break;
        case NXMCallHandlerServer:
            [self startServerCall:callees delegate:delegate completion:completion];
            break;
        default:
            break;
    }
    [NXMLogger debug:@"exit"];
}

#pragma mark - push

- (void)enablePushNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
                                     isPushKit:(BOOL)isPushKit
                                     isSandbox:(BOOL)isSandbox
                                    completion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [NXMLogger debugWithFormat:@"%@ %d %d entry", [[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding], isPushKit, isSandbox];
    if (![self isConnected]){
        [NXMLogger info:@"NXMClient:enablePushNotificationsWithDeviceToken:SDK disconnected"];
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completion(resError);
        return;
    }
    [self.stitchContext.coreClient enablePushNotificationsWithDeviceToken:deviceToken isSandbox:isSandbox isPushKit:isPushKit onSuccess:^{
        [NXMLogger info:@"Nexmo push notifications enabled"];
        [NXMBlocksHelper runWithError:nil completion:completion];
    } onError:^(NSError * _Nullable error) {
        [NXMLogger errorWithFormat:@"Nexmo push notifications enabling failed with error: %@", error];
        [NXMBlocksHelper runWithError:error completion:completion];
    }];
    [NXMLogger debug:@"exit"];
}

- (void)disablePushNotificationsWithCompletion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [NXMLogger debugWithFormat:@"entry"];

    if (![self isConnected]){
        [NXMLogger info:@"NXMClient:disablePushNotificationsWithCompletion:SDK disconnected"];
        NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeSDKDisconnected userInfo:nil];
        completion(resError);
        return;
    }
    [self.stitchContext.coreClient disablePushNotificationsWithOnSuccess:^{
        [NXMLogger info:@"Nexmo push notifications disabled"];
        [NXMBlocksHelper runWithError:nil completion:completion];
    } onError:^(NSError * _Nullable error) {
        [NXMLogger errorWithFormat:@"Nexmo push notifications disabling failed with error: %@", error];
        [NXMBlocksHelper runWithError:error completion:completion];
    }];
    [NXMLogger debug:@"exit"];

}

- (BOOL)isNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo {
    [NXMLogger debugWithFormat:@"%@", userInfo];
    return [self.stitchContext.coreClient isNexmoPushWithUserInfo:userInfo];
    
}

- (void)processNexmoPushWithUserInfo:(nonnull NSDictionary *)userInfo completion:(void(^_Nullable)(NSError * _Nullable error))completion {
    [NXMLogger debugWithFormat:@"%@ entry", userInfo];

    [NXMLogger debugWithFormat:@"Processing nexmo push with userInfo:%@", userInfo];
    [self.stitchContext.coreClient processNexmoPushWithUserInfo:userInfo onSuccess:^(NXMEvent * _Nullable event) {
        [NXMBlocksHelper runWithError:nil completion:completion];
    } onError:^(NSError * _Nullable error) {
        [NXMLogger debugWithFormat:@"Error processing nexmo push with error:%@", error];
        [NXMBlocksHelper runWithError:error completion:completion];
    }];
    [NXMLogger debug:@"exit"];
}


#pragma mark - notification center

- (void)onMemberEvent:(NSNotification* )notification {
    [NXMLogger debugWithFormat:@"%@ entry", notification.name];
    NXMMemberEvent* event = [NXMEventsDispatcherNotificationHelper<NXMMemberEvent *> nxmNotificationModelWithNotification:notification];
    
    if (![event.user.userId isEqualToString:self.user.userId]) { return; }
    /*
     Three types of events
     1. incoming conversation (Joined + Someone else invite you + no knocking id)
     2. incoming IP call (Invited + media enabled)
     3. out going server call (Joined + knocking Id exist)
    */
    //Incoming conversation
    if (event.state == NXMMemberStateJoined && ![event.fromMemberId isEqualToString:event.memberId] && !event.knockingId) {
        if ([self.delegate respondsToSelector:@selector(addedToConversation:)]) {            
            [NXMLogger info:@"got member joined event"];
            
            [self getConversationWithId:event.conversationId completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
                if (error) {
                    [NXMLogger error:[NSString stringWithFormat:@"get conversation failed %@", error]];
                    return;
                }
                
                if (!conversation) {
                    [NXMLogger error:[NSString stringWithFormat:@"got empty conversation without error conversation id %@:", event.conversationId]];
                }
                
                [self.delegate addedToConversation:conversation];
            }];
            
        }
        
        return;
    }
    //Incoming IP call
    if (event.state == NXMMemberStateInvited && event.media.isEnabled) {
        if ([self.delegate respondsToSelector:@selector(incomingCall:)]) { // optimization
            
            [NXMLogger info:@"got member invited event with enable media"];
            
            [self getConversationWithId:event.conversationId completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
                if (error) {
                    [NXMLogger error:[NSString stringWithFormat:@"get conversation failed %@", error]];
                    return;
                }

                if (!conversation){
                    [NXMLogger error:[NSString stringWithFormat:@"got empty conversation without error conversation id %@:", event.conversationId]];
                }
                
                if (!([conversation.displayName hasPrefix:NXMCallPrefix] || // IP-IP CS
                      !event.fromMemberId)) { // IP-IP VAPI
                    [NXMLogger error:@"member invited event with media enabled without call perfix"];
                    return;
                }
                
                NXMCall * call = [[NXMCall alloc] initWithConversation:conversation];
                [self.delegate incomingCall:call];
                
            }];
            
        }
    }
    //Out going server call
    if (event.state == NXMMemberStateJoined && event.knockingId){
        [NXMLogger info:@"got member JOINED event with knockingId"];
        
        [self getConversationWithId:event.conversationId completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation) {
            if (error) {
                [NXMLogger error:[NSString stringWithFormat:@"get conversation failed %@", error]];
                return;
            }
            
            if (!conversation){
                [NXMLogger error:[NSString stringWithFormat:@"got empty conversation without error conversation id %@:", event.conversationId]];
            }
            [conversation enableMedia:event.memberId];
            NXMCall * call = [[NXMCall alloc] initWithConversation:conversation];
            if (event.knockingId && self.knockingIdsToCompletion[event.knockingId]){
                NXMKnockingObj *obj = self.knockingIdsToCompletion[event.knockingId];
                call.delegate = obj.delegate;
                obj.complition(nil, call);
                [self.knockingIdsToCompletion removeObjectForKey:event.knockingId];
            } else {
                //TODO: check if this is a valid state for a call
                //this could happened if we get the member events before cs return the knocking id
                //to prevent drop calls we use the Incoming IP call
                [self.delegate incomingCall:call];
            }
        }];
    }
    [NXMLogger debug:@"exit"];

}

#pragma mark - private

- (BOOL)setUpWithErrorPtr:(NSError **)errorPtr {
    [NXMLogger debug:@""];
    //TODO: set up, set error and return false if problematic
    return YES;
}

- (BOOL)cleanUpWithErrorPtr:(NSError **)errorPtr {
    [NXMLogger debug:@""];
    //TODO: clean up, set error and return false if problematic
    return YES;
}

@end
