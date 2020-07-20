//
//  NXMRouter.m
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NXMRouter.h"
#import "NXMErrorsPrivate.h"
#import "NXMErrorParser.h"
#import "NXMLoggerInternal.h"
#import "NXMClientDefine.h"
#import "NXMConversationPrivate.h"
#import "NXMConversationIdsPage.h"
#import "NXMPagePrivate.h"
#import "NXMPageRequest.h"
#import "NXMNetworkCallbacks.h"
#import "NXMUtils.h"
#import "NXMMemberPrivate.h"
#import "NXMUserPrivate.h"
#import "NXMPageResponse.h"

#import "NXMSipEvent.h"
#import "NXMRtcAnswerEvent.h"
#import "NXMEventCreator.h"

static NSString * const PAGE_ORDER_ASC = @"ASC";
static NSString * const PAGE_ORDER_DESC = @"DESC";

static NSUInteger const CONVERSATIONS_PAGE_SIZE_MIN = 1;
static NSUInteger const CONVERSATIONS_PAGE_SIZE_MAX = 100;

static NSString * const CREATE_CONVERSATION_URL_FORMAT =@"%@beta/conversations";
static NSString * const EVENTS_URL_FORMAT = @"%@beta/conversations/%@/events";
static NSString * const CONVERSATIONS_PAGE_PER_USER_URL_FORMAT = @"%@beta2/users/%@/conversations";
static NSString * const EVENTS_PAGE_URL_FORMAT = @"%@beta2/conversations/%@/events";
static NSString * const ENABLE_PUSH_URL_FORMAT = @"%@beta2/devices/%@";
static NSString * const DISABLE_PUSH_URL_FORMAT = @"%@beta/devices/%@";
static NSString * const MEMBERS_URL_FORMAT = @"%@beta/conversations/%@/members";
static NSString * const MEMBERS_REMOVE_URL_FORMAT = @"%@beta/conversations/%@/members/%@";

@interface NXMRouter()

@property NSString *baseUrl;
@property (nonatomic, nonnull) NSURL *ipsURL;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *sessionId;
@property (nonatomic) NSString *agentDescription;

@end

@implementation NXMRouter

- (instancetype)initWithHost:(NSString *)host ipsURL:(NSURL *)ipsURL {
    if (self = [super init]) {
        self.baseUrl = host;
        self.ipsURL = ipsURL;

        self.agentDescription = [NSString stringWithFormat:@"NexmoClientSDK/%@ iOS (%@ %@ %@)",
                                 [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey: @"CFBundleShortVersionString"],
                                 [UIDevice currentDevice].systemName,
                                 [UIDevice currentDevice].systemVersion,
                                 [NXMUtils deviceMachineName]];
    }
    
    return self;
}

- (void)setToken:(NSString *)token {
    _token = token;
}

- (void)setSessionId:(nonnull NSString *)sessionId {
    _sessionId = sessionId;
}

#pragma mark - push

- (void)enablePushNotifications:(nonnull NXMEnablePushRequest *)request
                      onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG("");
    NSString *pushKitToken = [self hexadecimalString:request.pushKitToken];
    NSString *userNotificationToken = [self hexadecimalString:request.userNotificationToken];
    
    NSMutableDictionary *tokens = [NSMutableDictionary dictionary];
    
    if ([pushKitToken length] > 0) {
        [tokens setValue:@{
                           @"token": pushKitToken ,
                           @"bundle_id": [[NSBundle mainBundle].bundleIdentifier stringByAppendingString: @".voip"]
                           }
                  forKey:@"voip"];
    }
    
    if ([userNotificationToken length] > 0) {
        [tokens setValue:@{
                           @"token": userNotificationToken,
                           @"bundle_id": [NSBundle mainBundle].bundleIdentifier
                           }
                  forKey:@"push"];
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"ios" forKey:@"device_type"];
    [dict setValue:tokens forKey:@"tokens"];
    if(request.isSandbox) {
        [dict setValue:@"sandbox" forKey:@"device_push_environment"];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ENABLE_PUSH_URL_FORMAT, self.baseUrl, [NXMUtils nexmoDeviceId]]];
    
    [self requestToServer:dict url:url httpMethod:@"PUT" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        onSuccess();
    }];
}

- (void)disablePushNotificationsWithOnSuccess:(NXMSuccessCallback _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:DISABLE_PUSH_URL_FORMAT, self.baseUrl, [NXMUtils nexmoDeviceId]]];
    
    [self requestToServer:@{} url:url httpMethod:@"DELETE" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        onSuccess();
    }];
}

- (NSString *)getDeviceId {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}


#pragma mark - conversation



- (void)createConversation:(nonnull NXMCreateConversationRequest*)createConversationRequest
                 onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                   onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG([createConversationRequest.displayName UTF8String]);
    NSError *jsonErr;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"display_name": createConversationRequest.displayName} options:0 error: &jsonErr];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:CREATE_CONVERSATION_URL_FORMAT, self.baseUrl]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:[NXMErrorParser parseError:data] userInfo:nil];
            onError(resError);
            return;
        }
        
        NSString *convId = (NSString *)data[@"id"];
        if (!convId) {
            // TODO: error conv failed
            onError([[NSError alloc] initWithDomain:@"f" code:0 userInfo:nil]);
            return;
        }
        
      //  NSString *conv = convId;
        onSuccess(convId);
        
    }];
}

- (void)getConversationsForUser:(NSString *)userId
                      onSuccess:(NXMSuccessCallbackWithConversations _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@beta/users/%@/conversations", self.baseUrl, userId]];
    NXM_LOG_DEBUG([[url description] UTF8String]);
    
    NSString* requestType = @"GET";
    [self requestToServer:nil url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        
        if (error) {
            onError(error);
            return;
        }
        
        if (!data){
            onError([[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeUnknown userInfo:nil]);
            return;
        }
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSDictionary* detailsJson in data) {
            NXMConversationDetails *detail = [[NXMConversationDetails alloc] init];
            detail.displayName = detailsJson[@"display_name"];
            detail.members = @[];
            detail.name = detailsJson[@"name"];
            detail.sequence_number = [detailsJson[@"sequence_number"] integerValue];
            detail.conversationId = detailsJson[@"id"];
            
            [items addObject:detail];
        }
        
        onSuccess(items, nil);
    }];
}

- (void)getConversationIdsPageWithSize:(NSUInteger)size
                                cursor:(NSString *)cursor
                                userId:(NSString *)userId
                                 order:(NXMPageOrder)order
                                filter:(NSString*_Nullable)filter
                             onSuccess:(void (^)(NXMConversationIdsPage * _Nullable))onSuccess
                               onError:(void (^)(NSError * _Nullable))onError {

    NSUInteger cappedSize = MAX(CONVERSATIONS_PAGE_SIZE_MIN,
                                MIN(size, CONVERSATIONS_PAGE_SIZE_MAX));

    NXM_LOG_DEBUG([NSString stringWithFormat: @"UserID: %@; Page size: %@", userId, @(cappedSize)].UTF8String);

    NSString *urlString = [NSString stringWithFormat:CONVERSATIONS_PAGE_PER_USER_URL_FORMAT, self.baseUrl, userId];
    NSURL *url = [NSURL URLWithString: urlString];
    NSString *orderValue = [NXMRouter pageOrderStringFrom:order];
    NXMPageRequest *pageRequest = [[NXMPageRequest alloc] initWithPageSize:@(cappedSize).unsignedIntValue
                                                                   withUrl:url
                                                                withCursor:cursor
                                                                 withOrder:orderValue
                                                                withFilter:filter
                                                            withFilterName:@"state"];
    [self requestWithPageRequest:pageRequest
                 completionBlock:^(NSError * _Nullable error, NXMPageResponse * _Nullable pageResponse) {
                     if (error) {
                         onError(error);
                         return;
                     }
                     
                     NXMConversationIdsPage *page = [[NXMConversationIdsPage alloc] initWithPageResponse:pageResponse order:order];
                     onSuccess(page);
                 }];
}

- (void)getConversationIdsPageForURL:(NSURL *)url
                           onSuccess:(void (^)(NXMConversationIdsPage * _Nullable))onSuccess
                             onError:(void (^)(NSError * _Nullable))onError {
    [self requestToServer:nil url:url
               httpMethod:@"GET"
          completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
              if (error) {
                  onError(error);
                  return;
              }

              NXMConversationIdsPage *page = [[NXMConversationIdsPage alloc] initWithPageResponse:[[NXMPageResponse alloc] initWithData:data]
                                                                                    order:[NXMRouter parseOrderFromURL:url]];
              onSuccess(page);
          }];
}

- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(NXMSuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG([conversationId UTF8String]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@beta/conversations/%@", self.baseUrl, conversationId]];
    
    NSString* requestType = @"GET";
    
    [self requestToServer:nil url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        
        if (error) {
            onError(error);
            return;
        }
        
        if (!data){
            onError([[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeUnknown userInfo:nil]);
            return;
        }
        
        NXM_LOG_DEBUG("get conversation details %s",[data.description UTF8String]);
        
        
        NXMConversationDetails *details = [[NXMConversationDetails alloc] initWithConversationId:conversationId];
        details.name = data[@"name"];
        details.created = data[@"timestamp"][@"created"];
        details.sequence_number = [data[@"sequence_number"] intValue];
        details.properties = data[@"properties"];
        details.conversationId = data[@"uuid"];
        details.displayName = data[@"display_name"];
        
        NSMutableArray *members = [[NSMutableArray alloc] init];
        
        for (NSDictionary* memberJson in data[@"members"]) {
            [members addObject:[[NXMMember alloc] initWithData:memberJson
                                          andMemberIdFieldName:@"member_id"
                                             andConversationId:data[@"uuid"]]];
        }
        
        details.members = members;
        onSuccess(details);
    }];
}

#pragma mark - users

- (void)getUser:(nonnull NSString*)userId
completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock{
    NXM_LOG_DEBUG([userId UTF8String]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@beta/users/%@", self.baseUrl, userId]];
    
    NSString* requestType = @"GET";
    [self requestToServer:nil url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        if (data != nil){
            NXM_LOG_DEBUG("getUser result %s",[data.description UTF8String]);
            
            NXMUser *user = [[NXMUser alloc] initWithData:data];
            
            completionBlock(nil, user);
        }
        else{
            completionBlock(error,nil);
        }
    }];
}

- (void)inviteUserToConversation:(nonnull NXMInviteUserRequest *)inviteUserRequest
                       onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError {
    NSMutableDictionary *dict = [@{
                           @"user_name": inviteUserRequest.username,
                           @"action": @"invite",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           } mutableCopy];
    
    if (inviteUserRequest.mediaEnabled) {
        dict[@"media"] = @{
                   @"audio": @YES
                   };
    };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MEMBERS_URL_FORMAT, self.baseUrl, inviteUserRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess([[NXMMember alloc] initWithData:data
                             andMemberIdFieldName:@"id"
                                andConversationId:inviteUserRequest.conversationID]);
    }];
}

- (NSString *)joinUserToConversation:(nonnull NXMAddUserRequest*)addUserRequest
                    onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
                      onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG([addUserRequest.username UTF8String]);
    
    NSString *clientRef = [[NSUUID UUID] UUIDString];
    
    NSDictionary *dict = @{
                           @"client_ref": clientRef,
                           @"user_name": addUserRequest.username,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MEMBERS_URL_FORMAT, self.baseUrl, addUserRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess([[NXMMember alloc] initWithData:data
                             andMemberIdFieldName:@"id"
                                andConversationId:addUserRequest.conversationID]);
    }];
    
    return clientRef;
}

- (NSString *)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMembetRequest
                       onSuccess:(NXMSuccessCallbackWithId)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG([joinMembetRequest.memberID UTF8String]);
    
    NSString *clientRef = [[NSUUID UUID] UUIDString];
    
    NSDictionary *dict = @{
                           @"client_ref": clientRef,
                           @"member_id": joinMembetRequest.memberID,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MEMBERS_URL_FORMAT, self.baseUrl, joinMembetRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
    
    return clientRef;
}

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
                           onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                             onError:(NXMErrorCallback _Nullable)onError{
    NXM_LOG_DEBUG([removeMemberRequest.memberID UTF8String]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MEMBERS_REMOVE_URL_FORMAT, self.baseUrl, removeMemberRequest.conversationID, removeMemberRequest.memberID]];
    
    [self requestToServer:nil url:url httpMethod:@"DELETE" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}

#pragma mark - call

- (void)invitePstnToConversation:(nonnull NXMInvitePstnRequest *)invitePstnRequest
                       onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError{
    NSDictionary *dict = @{
                           @"user_id": invitePstnRequest.userID,
                           @"action": @"invite",
                           @"channel": @{
                                   @"type": @"phone",
                                   @"to":@{
                                       @"type": @"phone",
                                       @"number": invitePstnRequest.phoneNumber
                                   }
                                }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:MEMBERS_URL_FORMAT, self.baseUrl, invitePstnRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}


- (NSString *)invitePstnKnockingToConversation:(nonnull NXMInvitePstnKnockingRequest *)invitePstnRequest
                               onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                                 onError:(NXMErrorCallback _Nullable)onError{
    NSString *clientRef = [[NSUUID UUID] UUIDString];
    NXM_LOG_DEBUG("user %s phone %s", [invitePstnRequest.userName UTF8String], [invitePstnRequest.phoneNumber UTF8String]);
    
    NSDictionary *dict = @{
                     @"client_ref": clientRef,
                      @"channel": @{
                              @"type": @"app",
                              @"from":@{
                                      @"type":@"app",
                                      @"user":invitePstnRequest.userName
                                      },
                              @"to":@{
                                      @"type": @"phone",
                                      @"number": invitePstnRequest.phoneNumber
                                      }
                              }
                      };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@beta/knocking", self.baseUrl]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(data[@"id"]); // TODO: eventId;
    }];
    
    return clientRef;
}


#pragma mark - media
//TODO: change to createRTC/DestroyRTC
- (void)enableMedia:(NSString *)conversationId memberId:(NSString *)memberId sdp:(NSString *)sdp mediaType:(NSString *)mediaType // TODO: enum
          onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
            onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG("convId %s : memberId %s", [conversationId UTF8String], [memberId UTF8String]);
    NSDictionary *dict = @{ @"from": memberId,
                            @"body": @{
                                    @"offer": @{
                                            @"sdp": sdp,
                                            @"label": @""
                                            }
                                    },
                            @"originating_session": self.sessionId };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@beta/conversations/%@/rtc", self.baseUrl, conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        onSuccess(data[@"rtc_id"]);
    }];
}

// TODO: member id not found error
- (void)disableMedia:(NSString *)conversationId
               rtcId:(NSString *)rtcId
            memberId:(NSString *)memberId
           onSuccess:(NXMSuccessCallback _Nullable)onSuccess
             onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG("convId %s : memberId %s : rtcId %s", [conversationId UTF8String] , [memberId UTF8String], [rtcId UTF8String]);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@beta/conversations/%@/rtc/%@?from=%@&originating_session=%@", self.baseUrl, conversationId, rtcId, memberId, self.sessionId]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0]; // TODO: timeout
    [self addHeader:request];
    
    [self requestToServer:nil url:url httpMethod:@"DELETE" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        onSuccess();
    }];
}

- (void)muteAudioInConversation:(nonnull NSString *) conversationId
                     fromMember:(nonnull NSString *)fromMemberId
                       toMember:(nonnull NSString *)toMemberId
                      withRtcId:(nullable NSString *)rtcId
                      onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG("convId %s : memberId %s : rtcId %s", [conversationId UTF8String] , [fromMemberId UTF8String], [rtcId UTF8String]);

    NSDictionary *dict = @{ @"type": @"audio:mute:on",
                            @"from": fromMemberId,
                            @"to": toMemberId,
                            @"body": @{
                                    @"rtc_id": rtcId ? rtcId : [NSNull null]
                                    }
                            };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EVENTS_URL_FORMAT, self.baseUrl, conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        onSuccess();
    }];
}

- (void)unmuteAudioInConversation:(nonnull NSString *) conversationId
                       fromMember:(nonnull NSString *)fromMemberId
                         toMember:(nonnull NSString *)toMemberId
                        withRtcId:(nullable NSString *)rtcId
                        onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                          onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG("convId %s : memberId %s : rtcId %s", [conversationId UTF8String] , [fromMemberId UTF8String], [rtcId UTF8String]);

    NSDictionary *dict = @{ @"type": @"audio:mute:off",
                            @"from": fromMemberId,
                            @"to": toMemberId,
                            @"body": @{
                                    @"rtc_id": rtcId ? rtcId : [NSNull null]
                                    }
                            };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EVENTS_URL_FORMAT, self.baseUrl, conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        onSuccess();
    }];
}

#pragma mark - custom events

- (void)sendCustomEvent:(nonnull NXMSendCustomEventRequest *)sendCustomEventRequest
              onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG([sendCustomEventRequest.conversationId UTF8String]);

    NSDictionary *dict = @{
                           @"from": sendCustomEventRequest.memberId,
                           @"type": [NSString stringWithFormat:@"custom:%@", sendCustomEventRequest.customType],
                           @"body": sendCustomEventRequest.body
                           };
                    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EVENTS_URL_FORMAT, self.baseUrl, sendCustomEventRequest.conversationId]];
    
    [self requestToServer:dict
                      url:url
               httpMethod:@"POST"
          completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        NSString *eventId = [data[@"id"] stringValue];
              
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(eventId);
    }];
}

#pragma mark - message

- (void)sendDTMFToConversation:(nonnull NXMSendDTMFRequest*) sendDTMFRequest
                     onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG([sendDTMFRequest.conversationId UTF8String]);
    
    NSDictionary *dict = @{
                           @"from": sendDTMFRequest.memberId,
                           @"type": @"audio:dtmf",
                           @"body": @{
                                   @"digit": sendDTMFRequest.digit
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EVENTS_URL_FORMAT, self.baseUrl, sendDTMFRequest.conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        NSString *textId = [data[@"id"]stringValue];
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(textId); // TODO: eventId;
    }];
}

- (void)sendTextToConversation:(nonnull NXMSendTextEventRequest*)sendTextEventRequest
                     onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError {
    NXM_LOG_DEBUG([sendTextEventRequest.conversationID UTF8String]);

    NSDictionary *dict = @{
                           @"from": sendTextEventRequest.memberID,
                           @"type": @"text",
                           @"body": @{
                                   @"text": sendTextEventRequest.textToSend
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EVENTS_URL_FORMAT, self.baseUrl, sendTextEventRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        NSString *textId = [data[@"id"]stringValue];
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(textId); // TODO: eventId;
    }];
}

- (void)sendImage:(nonnull NXMSendImageRequest *)sendImageRequest
        onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
          onError:(NXMErrorCallback _Nullable)onError {
    
    NSDictionary *headers = @{ @"content-type": @"multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
                               @"authorization": [NSString stringWithFormat:@"bearer %@", self.token],
                               @"X-Nexmo-Trace-Id": self.sessionId.length > 0 ? self.sessionId : @"",
                               @"User-Agent": self.agentDescription
                               };

    NSString *boundary = @"----WebKitFormBoundary7MA4YWxkTrZu0gW";
    
    NSDictionary *params = @{@"quality_ratio"     : @"100",
                            @"thumbnail_size_ratio"    : @"30",
                            @"medium_size_ratio" : @"50"};
    
    NSMutableData *httpBody = [NSMutableData data];
    
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", sendImageRequest.imageName] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:sendImageRequest.image];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.ipsURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:httpBody];

    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        
        NSDictionary *dict = @{
                               @"from": sendImageRequest.memberId,
                               @"type": @"image",
                               @"body": @{@"representations": data }
                               };
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EVENTS_URL_FORMAT, self.baseUrl, sendImageRequest.conversationId]];
        
        [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
            NSString *textId = [data[@"id"]stringValue];
            if (error) {
                onError(error);
                return;
            }
            
            onSuccess(textId); // TODO: eventId;
        }];
    }];

}

#pragma mark - events

- (void)deleteEventFromConversation:(nonnull NXMDeleteEventRequest*)deleteEventRequest
                         onSuccess:(NXMSuccessCallback _Nullable)onSuccess
                           onError:(NXMErrorCallback _Nullable)onError {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@beta/conversations/%@/events/%ld?from=%@", self.baseUrl, deleteEventRequest.conversationID,(long)deleteEventRequest.eventID, deleteEventRequest.memberID]];
    
    NSString* requestType = @"DELETE";
    [self requestToServer:nil url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(); // TODO: eventId;
    }];
}

- (void)getLatestEvent:(NXMGetEventsRequest *) getEventsRequest onSuccess:(NXMSuccessCallbackWithEvent)onSuccess onError:(NXMErrorCallback)onError{
    NXM_LOG_DEBUG([getEventsRequest.conversationId UTF8String]);
    [self getEvents:getEventsRequest onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
        if (events && [events count] > 0){
            onSuccess([events firstObject]);
        }
        else{
            NXM_LOG_DEBUG("getLatestEvent converationId:%@ no events",getEventsRequest.conversationId);
        }
    } onError:^(NSError * _Nullable error) {
        onError(error);
    }];
}

- (void)getEvents:(NXMGetEventsRequest *)getEventsRequest onSuccess:(NXMSuccessCallbackWithEvents)onSuccess onError:(NXMErrorCallback)onError{
    NXM_LOG_DEBUG([getEventsRequest.conversationId UTF8String]);

    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:[NSString stringWithFormat:EVENTS_PAGE_URL_FORMAT, self.baseUrl, getEventsRequest.conversationId]];
    
    NSMutableArray<NSURLQueryItem *> *queryParams = [NSMutableArray new];
    if(getEventsRequest.startId) {
        [queryParams addObject:[[NSURLQueryItem alloc] initWithName:@"start_id" value:[getEventsRequest.startId stringValue]]];
    }
    if(getEventsRequest.endId) {
        [queryParams addObject:[[NSURLQueryItem alloc] initWithName:@"end_id" value:[getEventsRequest.endId stringValue]]];
    }
    urlComponents.queryItems = queryParams;
    NSURL *url = urlComponents.URL;
    
    NXMPageRequest * pageRequest = [[NXMPageRequest alloc] initWithPageSize:60 withUrl:url withCursor:nil withOrder:getEventsRequest.order withFilter:nil withFilterName:@"event_type"];
    [self requestWithPageRequest:pageRequest completionBlock:^(NSError * _Nullable error, NXMPageResponse * _Nullable pageResponse) {
        if (error){
            onError(error);
            return;
        }
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (NSDictionary* eventJson in pageResponse.data) {
            NSString* type = eventJson[@"type"];
            
            NXMEvent *event =  [NXMEventCreator createEvent:type data:eventJson conversationUuid:getEventsRequest.conversationId];
            if (event) {
                [events addObject:event];
            }
        }
        
        onSuccess(events);
    }];
}

- (void)getEventsPageWithRequest:(NXMGetEventsPageRequest *)request
               eventsPagingProxy:(id<NXMPageProxy>)proxy
                       onSuccess:(void (^)(NXMEventsPage * _Nullable))onSuccess
                         onError:(void (^)(NSError * _Nullable))onError {
    NXM_LOG_DEBUG(request.conversationId.UTF8String);

    NSString *urlString = [NSString stringWithFormat:EVENTS_PAGE_URL_FORMAT, self.baseUrl, request.conversationId];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlString];
    NSURL *url = urlComponents.URL;
    NSString *orderValue = [NXMRouter pageOrderStringFrom:request.order];
    NXMPageRequest *pageRequest = [[NXMPageRequest alloc] initWithPageSize:@(request.size).unsignedIntValue
                                                                   withUrl:url
                                                                withCursor:request.cursor
                                                                 withOrder:orderValue
                                                                withFilter:request.eventType
                                                            withFilterName:@"event_type"];
    [self requestWithPageRequest:pageRequest
                 completionBlock:^(NSError * _Nullable error, NXMPageResponse * _Nullable pageResponse) {
                     if (error) {
                         onError(error);
                         return;
                     }

                     NSArray<NXMEvent *> *events = [self eventsFromPageResponse:pageResponse withConversationId:request.conversationId];
                     NXMEventsPage *page = [[NXMEventsPage alloc] initWithOrder:request.order
                                                                   pageResponse:pageResponse
                                                                    pagingProxy:proxy
                                                                       elements:events];
                      onSuccess(page);
                 }];
}

- (void)getEventsPageForURL:(NSURL *)url
          eventsPagingProxy:(id<NXMPageProxy>)proxy
                  onSuccess:(void (^)(NXMEventsPage * _Nullable))onSuccess
                    onError:(void (^)(NSError * _Nullable))onError {
    [self requestToServer:nil
                      url:url
               httpMethod:@"GET"
          completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
              if (error) {
                  onError(error);
                  return;
              }

              NSString *conversationId = [NXMRouter parseConversationIdFromURL:url];
              if (conversationId == nil) {
                  onError([NXMErrors nxmErrorWithErrorCode:NXMErrorCodeUnknown]);
                  return;
              }

              NXMPageResponse *pageResponse = [[NXMPageResponse alloc] initWithData:data];
              NSArray<NXMEvent *> *events = [self eventsFromPageResponse:pageResponse withConversationId:conversationId];
              NXMEventsPage *page = [[NXMEventsPage alloc] initWithOrder:[NXMRouter parseOrderFromURL:url]
                                                            pageResponse:pageResponse
                                                             pagingProxy:proxy
                                                                elements:events];
              onSuccess(page);
          }];
}

#pragma mark - private

- (nonnull NSArray<NXMEvent *> *)eventsFromPageResponse:(nullable NXMPageResponse *)pageResponse
                                     withConversationId:(nonnull NSString *)conversationId {
    NSMutableArray<NXMEvent *> *events = [NSMutableArray new];
    for (NSDictionary *eventJson in pageResponse.data) {
        NSString *type = eventJson[@"type"];

        NXMEvent * event = [NXMEventCreator createEvent:type data:eventJson conversationUuid:conversationId];

        if (event) {
            [events addObject:event];
        }
    }
    return events;
}

+ (nonnull NSString *)pageOrderStringFrom:(NXMPageOrder)order {
    return order == NXMPageOrderAsc ? PAGE_ORDER_ASC : PAGE_ORDER_DESC;
}

- (void)requestWithPageRequest:(nonnull NXMPageRequest *)pageRequest
               completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMPageResponse * _Nullable data))completionBlock {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:pageRequest.url resolvingAgainstBaseURL:NO];
    components.percentEncodedQuery = [NSString stringWithFormat:@"page_size=%u%@%@%@",
                                      pageRequest.pageSize,
                                      (pageRequest.cursor && [pageRequest.cursor length] > 0 ? [NSString stringWithFormat:@"&cursor=%@", pageRequest.cursor] : @""),
                                      (pageRequest.order && [pageRequest.order length] > 0 ? [NSString stringWithFormat:@"&order=%@", pageRequest.order] : @""),
                                      ((pageRequest.filterName && pageRequest.filter) ? [NSString stringWithFormat:@"&%@=%@", pageRequest.filterName, pageRequest.filter] : @"")];

    [self requestToServer:nil url:components.URL httpMethod:@"GET" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            completionBlock(error, nil);
            return;
        }
        
        completionBlock(nil, [[NXMPageResponse alloc] initWithData:data]);
    }];
}

#pragma mark - Requests

- (void)requestToServer:(nullable NSDictionary*)dict url:(nonnull NSURL*)url httpMethod:(nonnull NSString*)httpMethod completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock{
    NSError *jsonErr;
    NSData* jsonData = nil;
    
    if (dict){
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: &jsonErr];
    }
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    [self addHeader:request];
    
    [request setHTTPMethod:httpMethod];
    if (jsonData) {
        [request setHTTPBody:jsonData];
    }
    
    [self executeRequest:request responseBlock:completionBlock];
}

- (void)addHeader:(NSMutableURLRequest *)request {
    [request setValue:[NSString stringWithFormat:@"bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.sessionId.length > 0 ? self.sessionId : @"" forHTTPHeaderField:@"X-Nexmo-Trace-Id"];
    [request setValue:self.agentDescription forHTTPHeaderField:@"User-Agent"];
}

- (void)executeRequest:(NSURLRequest *)request  responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary *      _Nullable data))responseBlock {
    NXM_LOG_DEBUG([request.description UTF8String]);

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NXM_LOG_DEBUG("response %s %s %s", [response.description UTF8String], [data.description UTF8String], [error.description UTF8String]);
        if (error) {
            // TODO: network error
            responseBlock(error, nil);
            NXM_LOG_DEBUG("Got response %s with error %s.\n", [response.description UTF8String], [error.description UTF8String]);

            return;
        }
        
        // TODO: make this more robust
        if (((NSHTTPURLResponse *)response).statusCode == 413) {
            responseBlock([NXMErrors nxmErrorWithErrorCode:NXMErrorCodePayloadTooBig], nil);
            return;
        }
        
        NSError *jsonError;
        if (((NSHTTPURLResponse *)response).statusCode != 200){
            // TODO: map code from error msg
            NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:[NXMErrorParser parseErrorWithData:data] userInfo:dataDict];
            NXM_LOG_ERROR("response error %s", [resError.description UTF8String]);
            responseBlock(resError, nil);
            return;
        }
        NSDictionary *jsonDict = @{};
        if(data.length) {
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonDict || jsonError) {
                // TODO: map code from error msg
                NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:[NXMErrorParser parseErrorWithData:data] userInfo:nil];
                NXM_LOG_ERROR("response error %s", [resError.description UTF8String]);
                responseBlock(resError, nil);
                return;
            }
        }
        
        responseBlock(nil, jsonDict);
    }] resume];
}

#pragma mark Helper

- (NSString *)hexadecimalString:(NSData *)data {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

#pragma mark - Parser

+ (NXMPageOrder)parseOrderFromURL:(NSURL *)url {
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    
    NSUInteger orderIndex = [urlComponents.queryItems indexOfObjectPassingTest:^BOOL(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isEqualToString:@"order"];
    }];

    if (orderIndex == NSNotFound) {
        return NXMPageOrderAsc;
    }

    NSString *orderValue = urlComponents.queryItems[orderIndex].value;
    return [orderValue caseInsensitiveCompare:PAGE_ORDER_ASC] == NSOrderedSame
            ? NXMPageOrderAsc
            : NXMPageOrderDesc;
}

+ (nullable NSString *)parseConversationIdFromURL:(NSURL *)url {
    NSUInteger conversationsIndex = [url.pathComponents indexOfObjectPassingTest:^BOOL(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isEqualToString:@"conversations"];
    }];

    if (conversationsIndex == NSNotFound
        || conversationsIndex == url.pathComponents.count - 1) {
        return nil;
    }

    return url.pathComponents[1 + conversationsIndex];
}

@end
