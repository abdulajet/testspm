//
//  NXMRouter.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NXMRouter.h"
#import "NXMErrorsPrivate.h"
#import "NXMErrorParser.h"
#import "NXMAddUserRequest.h"
#import "NXMSendTextEventRequest.h"
#import "NXMDeleteEventRequest.h"
#import "NXMLogger.h"

#import "NXMNetworkCallbacks.h"
#import "NXMCoreEventsPrivate.h"
#import "NXMUtils.h"
#import "NXMMemberPrivate.h"
#import "NXMUserPrivate.h"
#import "NXMPageRequest.h"
#import "NXMPageResponse.h"

static NSString * const EVENTS_URL_FORMAT = @"%@conversations/%@/events";

@interface NXMRouter()

@property NSString *baseUrl;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *sessionId;
@property (nonatomic) NSString *agentDescription;


@end
@implementation NXMRouter

- (nullable instancetype)initWithHost:(nonnull NSString *)host {
    if (self = [super init]) {
        self.baseUrl = host;
        self.agentDescription = [NSString stringWithFormat:@"iOS %@ %@",
                                 [UIDevice currentDevice].systemVersion,
                                 [UIDevice currentDevice].model];
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
    
    NSString *deviceToken = [self hexadecimalString:request.deviceToken];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"device_token"] = deviceToken;
    dict[@"device_type"] = @"ios";
    dict[@"bundle_id"] = [[NSBundle mainBundle].bundleIdentifier stringByAppendingString: request.isPushKit ? @".voip" : @""];
    dict[@"device_push_environment"] = request.isSandbox ? @"sandbox" : @"production";
    
    NSString *deviceId = deviceToken; // This is not a bug!!!! we use device/push token as device id.
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@devices/%@", self.baseUrl, deviceId]];
    
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
    NSString *deviceId = [self getDeviceId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@devices/%@", self.baseUrl, deviceId]];
    
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
    NSError *jsonErr;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"display_name": createConversationRequest.displayName} options:0 error: &jsonErr];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations", self.baseUrl]];
    
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

- (BOOL)getConversationsPaging:( NSString* _Nullable )name dateStart:( NSString* _Nullable )dateStart  dateEnd:( NSString* _Nullable )dateEnd pageSize:(long)pageSize recordIndex:(long)recordIndex order:( NSString* _Nullable )order completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock{
    //TODO:for now we get the first 100 conversations
    //we need to have support in the server to get all the conversations
    NSString* vars = @"";
    if (pageSize > 0){
        vars = [NSString stringWithFormat:@"pageSize:%ld",MIN(100,pageSize)];
    }
    if (recordIndex > 0){
        vars = [NSString stringWithFormat:@"%@&&recordIndex:%ld",vars,recordIndex];
    }
    if (name != nil){
        vars = [NSString stringWithFormat:@"%@&&name:%@",vars,name];
    }
    if (dateStart != nil){
        vars = [NSString stringWithFormat:@"%@&&dateStart:%@",vars,dateStart];
    }
    if (dateEnd != nil){
        vars = [NSString stringWithFormat:@"%@&&dateEnd:%@",vars,dateEnd];
    }
    if (order != nil){
        vars = [NSString stringWithFormat:@"%@&&order:%@",vars,order];
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations?%@", self.baseUrl, vars]];
    
    NSString* requestType = @"GET";
    [self requestToServer:nil url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        if (data != nil){
            NSMutableArray *conversations = [[NSMutableArray alloc] init];
            for (NSDictionary* conversationJson in data[@"_embedded"][@"conversations"]){
                NXMConversationDetails *details = [NXMConversationDetails alloc];
                details.name = conversationJson[@"name"];
                details.conversationId = conversationJson[@"uuid"];
                [conversations addObject:details];
            }
            completionBlock(nil, conversations);
        }
        else{
            completionBlock(error,nil);
        }
    }];
    return YES;
}

- (void)getConversations:(nonnull NXMGetConversationsRequest*)getConvetsationsRequest
               onSuccess:(NXMSuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(NXMErrorCallback _Nullable)onError {
    //TODO:for now we get the first 100 conversations
    //we need to have support in the server to get all the conversations
    NSString* vars = @"";
    if (getConvetsationsRequest.pageSize > 0){
        vars = [NSString stringWithFormat:@"pageSize:%ld",MIN(100,getConvetsationsRequest.pageSize)];
    }
    
    if (getConvetsationsRequest.recordIndex > 0){
        vars = [NSString stringWithFormat:@"%@&&recordIndex:%ld",vars,getConvetsationsRequest.recordIndex];
    }
    
    if ([getConvetsationsRequest.name length] > 0){
        vars = [NSString stringWithFormat:@"%@&&name:%@",vars,getConvetsationsRequest.name];
    }
    
    if ([getConvetsationsRequest.dateStart  length] > 0){
        vars = [NSString stringWithFormat:@"%@&&dateStart:%@",vars,getConvetsationsRequest.dateStart];
    }
    
    if ([getConvetsationsRequest.dateEnd  length] > 0){
        vars = [NSString stringWithFormat:@"%@&&dateEnd:%@",vars,getConvetsationsRequest.dateEnd];
    }
    
    if ([getConvetsationsRequest.order  length] > 0){
        vars = [NSString stringWithFormat:@"%@&&order:%@",vars,getConvetsationsRequest.order];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations?%@", self.baseUrl, vars]];
    
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
        
        NSMutableArray *conversations = [[NSMutableArray alloc] init];
        for (NSDictionary* conversationJson in data[@"_embedded"][@"conversations"]){
            NXMConversationDetails *details = [NXMConversationDetails alloc];
            details.name = conversationJson[@"name"];
            details.conversationId = conversationJson[@"uuid"];
            [conversations addObject:details];
        }
        
        NXMPageInfo *pageInfo = [[NXMPageInfo alloc] initWithCount:data[@"count"]
                                                          pageSize:data[@"page_size"]
                                                       recordIndex:data[@"record_index"]];
        
        onSuccess(conversations, pageInfo);
    }];
}

- (void)getConversationsForUser:(NSString *)userId
                      onSuccess:(NXMSuccessCallbackWithConversations _Nullable)onSuccess
                        onError:(NXMErrorCallback _Nullable)onError {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/conversations", self.baseUrl, userId]];
    [NXMLogger infoWithFormat:@"%@",url];
    
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


- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(NXMSuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@", self.baseUrl, conversationId]];
    
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
        
        [NXMLogger infoWithFormat:@"get conversation details %@",data];
        
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@", self.baseUrl, userId]];
    
    NSString* requestType = @"GET";
    [self requestToServer:nil url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        if (data != nil){
            [NXMLogger infoWithFormat:@"getUser result %@",data];
            
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
                           @"user_id": inviteUserRequest.userID,
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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/members", self.baseUrl, inviteUserRequest.conversationID]];
    
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

- (void)addUserToConversation:(nonnull NXMAddUserRequest*)addUserRequest
                    onSuccess:(NXMSuccessCallbackWithObject _Nullable)onSuccess
                      onError:(NXMErrorCallback _Nullable)onError {

    NSDictionary *dict = @{
                           @"user_id": addUserRequest.userID,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/members", self.baseUrl, addUserRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess([[NXMMember alloc] initWithData:data
                             andMemberIdFieldName:@"id"
                                andConversationId:addUserRequest.conversationID]);
    }];
}

- (void)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMembetRequest
                       onSuccess:(NXMSuccessCallbackWithId)onSuccess
                         onError:(NXMErrorCallback _Nullable)onError {
    NSDictionary *dict = @{
                           @"member_id": joinMembetRequest.memberID,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/members", self.baseUrl, joinMembetRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
                           onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                             onError:(NXMErrorCallback _Nullable)onError{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/members/%@", self.baseUrl, removeMemberRequest.conversationID, removeMemberRequest.memberID]];
    
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/members", self.baseUrl, invitePstnRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}


- (void)invitePstnKnockingToConversation:(nonnull NXMInvitePstnKnockingRequest *)invitePstnRequest
                               onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                                 onError:(NXMErrorCallback _Nullable)onError{
    NSDictionary *dict = @{
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@knocking", self.baseUrl]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(data[@"id"]); // TODO: eventId;
    }];
}


#pragma mark - media
//TODO: change to createRTC/DestroyRTC
- (void)enableMedia:(NSString *)conversationId memberId:(NSString *)memberId sdp:(NSString *)sdp mediaType:(NSString *)mediaType // TODO: enum
          onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
            onError:(NXMErrorCallback _Nullable)onError {
    NSDictionary *dict = @{ @"from": memberId,
                            @"body": @{
                                    @"offer": @{
                                            @"sdp": sdp,
                                            @"label": @""
                                            }
                                    },
                            @"originating_session": self.sessionId };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/rtc", self.baseUrl, conversationId]];
    
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
    
    NSDictionary *dict = @{ @"from": memberId, @"originating_session": self.sessionId};
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/rtc/%@", self.baseUrl, conversationId, rtcId]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0]; // TODO: timeout
    [self addHeader:request];
    
    [self requestToServer:dict url:url httpMethod:@"DELETE" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
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

#pragma mark - message

- (void)sendTextToConversation:(nonnull NXMSendTextEventRequest*)sendTextEventRequest
                     onSuccess:(NXMSuccessCallbackWithId _Nullable)onSuccess
                       onError:(NXMErrorCallback _Nullable)onError {
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
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.nexmo.com/v1/image/"]
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
                               @"body": data
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
    NSDictionary *dict = @{
                           @"from": deleteEventRequest.memberID,
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations/%@/events/%ld", self.baseUrl, deleteEventRequest.conversationID,(long)deleteEventRequest.eventID]];
    
    NSString* requestType = @"DELETE";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(); // TODO: eventId;
    }];
}

- (void)getLatestEvent:(NXMGetEventsRequest *) getEventsRequest onSuccess:(NXMSuccessCallbackWithEvent)onSuccess onError:(NXMErrorCallback)onError{
    [self getEvents:getEventsRequest onSuccess:^(NSMutableArray<NXMEvent *> * _Nullable events) {
        if (events && [events count] > 0){
            onSuccess:[events firstObject];
        }
        else{
            [NXMLogger debugWithFormat:@"getLatestEvent converationId:%@ no events",getEventsRequest.conversationId ];
        }
    } onError:^(NSError * _Nullable error) {
        onError(error);
    }];
}

- (void)getEvents:(NXMGetEventsRequest *)getEventsRequest onSuccess:(NXMSuccessCallbackWithEvents)onSuccess onError:(NXMErrorCallback)onError{
    
    NSURLComponents *urlComponents = [NSURLComponents  componentsWithString:[NSString stringWithFormat:EVENTS_URL_FORMAT, @"https://api.nexmo.com/beta2/", getEventsRequest.conversationId]];
    NSMutableArray<NSURLQueryItem *> *queryParams = [NSMutableArray new];
    if(getEventsRequest.startId) {
        [queryParams addObject:[[NSURLQueryItem alloc] initWithName:@"start_id" value:[getEventsRequest.startId stringValue]]];
    }
    if(getEventsRequest.endId) {
        [queryParams addObject:[[NSURLQueryItem alloc] initWithName:@"end_id" value:[getEventsRequest.endId stringValue]]];
    }
    urlComponents.queryItems = queryParams;
    
    NSURL *url = urlComponents.URL;
    NSString* requestType = @"GET";
    
    NXMPageRequest* pageRequest = [[NXMPageRequest alloc] initWithPageSize:100 withUrl:url withCursor:nil withOrder:nil];
    [self requestWithPageRequest:pageRequest completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        if (!data){
            onError([[NSError alloc] initWithDomain:NXMErrorDomain code:NXMErrorCodeUnknown userInfo:nil]);
            return;
        }
        NXMPageResponse * pageResponse = [[NXMPageResponse alloc] initWithData:data];
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (NSDictionary* eventJson in pageResponse.data) {
            NSString* type = eventJson[@"type"];
            if ([type isEqual:@"member:joined"]) {
                [events addObject:[self parseMemberEvent:NXMMemberStateJoined dict:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if ([type isEqual:@"member:invited"]){
                [events addObject:[self parseMemberEvent:NXMMemberStateInvited dict:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if ([type isEqual:@"member:left"]){
                [events addObject:[self parseMemberEvent:NXMMemberStateLeft dict:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if ([type isEqual:@"member:media"]){
                [events addObject:[self parseMediaEvent:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if([type isEqual:@"audio:mute:on"]){
                [events addObject:[self parseAudioMuteOnEvent:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if([type isEqual:@"audio:mute:off"]){
                [events addObject:[self parseAudioMuteOffEvent:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if ([type isEqual:@"text:seen"]){
                [events addObject:[self parseMessageStatusEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMMessageStatusTypeSeen]];
                continue;
            }
            
            if ([type isEqual:@"text:delivered"]){
                [events addObject:[self parseMessageStatusEvent:eventJson conversationId:getEventsRequest.conversationId
                                                          state:NXMMessageStatusTypeDelivered]];
                continue;
            }
            
            if ([type isEqual:@"text"]){
                [events addObject:[self parseTextEvent:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if ([type isEqual:@"image"]){
                [events addObject:[self parseImageEvent:eventJson conversationId:getEventsRequest.conversationId]];
                continue;
            }
            
            if ([type isEqual:@"image:seen"]){
                [events addObject:[self parseMessageStatusEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMMessageStatusTypeSeen]];
                continue;
            }
            
            if ([type isEqual:@"image:delivered"]) {
                [events addObject:[self parseMessageStatusEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMMessageStatusTypeDelivered]];
                continue;
            }
            
            if ([type isEqual:@"event:deleted"]) {
                [events addObject:[self parseMessageStatusEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMMessageStatusTypeDeleted]];
                continue;
            }
            
            if ([type isEqual:@"sip:ringing"]) {
                [events addObject:[self parseSipEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMSipEventRinging]];
                continue;
            }
            
            if ([type isEqual:@"sip:answered"]){
                [events addObject:[self parseSipEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMSipEventAnswered]];
                continue;
            }
            
            if ([type isEqual:@"sip:hangup"]) {
                [events addObject:[self parseSipEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMSipEventHangup]];
                continue;
            }
            
            if ([type isEqual:@"sip:status"]) {
                [events addObject:[self parseSipEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMSipEventStatus]];
                continue;
            }
            
        }
        
        onSuccess(events);
    }];
    
    
}

#pragma mark - private

- (void)requestWithPageRequest:(NXMPageRequest*)pageRequets completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:pageRequets.url resolvingAgainstBaseURL:NO];
    NSMutableArray * newQueryItems = [NSMutableArray arrayWithCapacity:[components.queryItems count] + 1 + (pageRequets.cursor ? 1:0) + (pageRequets.order ? 1:0)];
    [newQueryItems addObject:[[NSURLQueryItem alloc] initWithName:@"page_size" value:[[NSString alloc] initWithFormat:@"%d",pageRequets.pageSize]]];
    if (pageRequets.cursor && [pageRequets.cursor length] > 0){
        [newQueryItems addObject:[[NSURLQueryItem alloc] initWithName:@"cursor" value:pageRequets.cursor]];
    }
    if (pageRequets.order && [pageRequets.order length] > 0){
        [newQueryItems addObject:[[NSURLQueryItem alloc] initWithName:@"order" value:pageRequets.order]];
    }

    [components setQueryItems:newQueryItems];
    [self requestToServer:nil url:[components URL] httpMethod:@"GET" completionBlock:completionBlock];
}

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
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            // TODO: network error
            responseBlock(error, nil);
            [NXMLogger infoWithFormat:@"Got response %@ with error %@.\n", response, error];

            return;
        }
        
        // TODO: make this more robust
        if (((NSHTTPURLResponse *)response).statusCode == 413) {
            responseBlock([NXMErrors nxmErrorWithErrorCode:NXMErrorCodePayloadTooBig andUserInfo:nil], nil);
            return;
        }
        
        NSError *jsonError;
        if (((NSHTTPURLResponse *)response).statusCode != 200){
            // TODO: map code from error msg
            NSDictionary* dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:[NXMErrorParser parseErrorWithData:data] userInfo:dataDict];
            responseBlock(resError, nil);
            return;
        }
        NSDictionary *jsonDict = @{};
        if(data.length) {
            jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (!jsonDict || jsonError) {
                // TODO: map code from error msg
                NSError *resError = [[NSError alloc] initWithDomain:NXMErrorDomain code:[NXMErrorParser parseErrorWithData:data] userInfo:nil];
                responseBlock(resError, nil);
                return;
            }
        }
        
        responseBlock(nil, jsonDict);
    }] resume];
}

- (NSString*)getType:(nonnull NSDictionary*)dict{
    return dict[@"type"];
}
- (NSString*)getSequenceId:(nonnull NSDictionary*)dict{
    return dict[@"id"];
}
- (NSString*)getFromMemberId:(nonnull NSDictionary*)dict{
    return dict[@"from"];
}
- (NSDate*)getCreationDate:(nonnull NSDictionary*)dict{
    return [NXMUtils dateFromISOString:dict[@"timestamp"]];
}

- (NXMMemberEvent* )parseMemberEvent:(NXMMemberState)state dict:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId{
    
    NSString *memberId = dict[@"body"][@"user"][@"member_id"] ?: dict[@"from"];
    
    NXMMemberEvent *memberEvent = [[NXMMemberEvent alloc] initWithConversationId:conversationId
                                                                      sequenceId:[[self getSequenceId:dict] integerValue]
                                                                        andState:state
                                                                         andData:dict[@"body"]
                                                                    creationDate:[self getCreationDate:dict]
                                                                        memberId:memberId];
    
    return memberEvent;
}

- (NXMMediaEvent* )parseMediaEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId{
    NXMMediaEvent* event = [[NXMMediaEvent alloc] init];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeMedia;
    
    if (dict[@"body"][@"audio"]){
        event.mediaSettings = [[NXMMediaSettings alloc] initWithEnabled:[dict[@"body"][@"media"][@"audio_settings"][@"enabled"] boolValue]
                                                                suspend:[dict[@"body"][@"media"][@"audio_settings"][@"muted"] boolValue]];
    } else if (dict[@"body"][@"video"]){
        event.mediaSettings = [[NXMMediaSettings alloc] initWithEnabled:[dict[@"body"][@"media"][@"video_settings"][@"enabled"] boolValue]
                                                                suspend:[dict[@"body"][@"media"][@"video_settings"][@"muted"] boolValue]];
    }
    
    return event;
}

- (NXMMediaActionEvent *)parseAudioMuteOnEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId{
    NXMMediaSuspendEvent* event = [NXMMediaSuspendEvent new];
    event.toMemberId = dict[@"to"];
    event.conversationId = dict[@"cid"];
    event.fromMemberId = dict[@"from"];
    event.creationDate = [NXMUtils dateFromISOString:dict[@"timestamp"]];
    event.sequenceId = [dict[@"id"] integerValue];
    event.type = NXMEventTypeMediaAction;
    event.actionType = NXMMediaActionTypeSuspend;
    event.mediaType = NXMMediaTypeAudio;
    event.isSuspended = true;
        
    return event;
}

- (NXMMediaActionEvent *)parseAudioMuteOffEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId{
    NXMMediaSuspendEvent* event = [NXMMediaSuspendEvent new];
    event.toMemberId = dict[@"to"];
    event.conversationId = dict[@"cid"];
    event.fromMemberId = dict[@"from"];
    event.creationDate = [NXMUtils dateFromISOString:dict[@"timestamp"]];
    event.sequenceId = [dict[@"id"] integerValue];
    event.type = NXMEventTypeMediaAction;
    event.actionType = NXMMediaActionTypeSuspend;
    event.mediaType = NXMMediaTypeAudio;
    event.isSuspended = false;
    
    return event;
}

- (NXMSipEvent* )parseSipEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId state:(NXMSipEventType )state{
    NXMSipEvent * event = [[NXMSipEvent alloc] init];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeSip;
    event.sipType = state;
    event.phoneNumber = dict[@"body"][@"channel"][@"to"][@"number"];
    event.applicationId = dict[@"application_id"];
    
    return event;
}
- (NXMMessageStatusEvent* )parseMessageStatusEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId state:(NXMMessageStatusType )state{
    NXMMessageStatusEvent * event = [[NXMMessageStatusEvent alloc] init];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeMessageStatus;
    event.status = state;
    event.eventId = [dict[@"body"][@"event_id"] integerValue];
    
    return event;
}

- (NXMTextEvent *)parseTextEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId {
    NXMTextEvent* event = [[NXMTextEvent alloc] init];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeText;
    event.text = dict[@"body"][@"text"];
    event.state = [self parseStateFromDictionary:dict[@"state"]];
    return event;
}

- (NXMImageEvent *)parseImageEvent:(nonnull NSDictionary*)json conversationId:(nonnull NSString*)conversationId {
    
    NXMImageEvent *imageEvent = [[NXMImageEvent alloc] initWithConversationId:conversationId
                                                                   sequenceId:[json[@"id"] integerValue]
                                                                 fromMemberId:json[@"from"]
                                                                 creationDate:[self getCreationDate:json]
                                                                         type:NXMEventTypeImage];
    NSDictionary *body = json[@"body"][@"representations"];
    imageEvent.imageId = body[@"id"];
    NSDictionary *originalJSON = body[@"original"];
    imageEvent.originalImage = [[NXMImageInfo alloc] initWithId:originalJSON[@"id"]
                                                             size:[originalJSON[@"size"] integerValue]
                                                              url:originalJSON[@"url"]
                                                             type:NXMImageTypeOriginal];
    
    NSDictionary *mediumJSON = body[@"medium"];
    imageEvent.mediumImage = [[NXMImageInfo alloc] initWithId:mediumJSON[@"id"]
                                                           size:[mediumJSON[@"size"] integerValue]
                                                            url:mediumJSON[@"url"]
                                                           type:NXMImageTypeMedium];
    
    
    NSDictionary *thumbnailJSON = body[@"thumbnail"];
    imageEvent.thumbnailImage = [[NXMImageInfo alloc] initWithId:thumbnailJSON[@"id"]
                                                              size:[thumbnailJSON[@"size"] integerValue]
                                                               url:thumbnailJSON[@"url"]
                                                              type:NXMImageTypeThumbnail];
    imageEvent.type = NXMEventTypeImage;
    
    imageEvent.state = [self parseStateFromDictionary:json[@"state"]];
    return imageEvent;
}

- (NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, NSDate *> *> *)parseStateFromDictionary:(NSDictionary *)dictionary {
    if(![dictionary isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        dict[@(NXMMessageStatusTypeSeen)] = @{};
        dict[@(NXMMessageStatusTypeDelivered)] = @{};
        
        return dict;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@(NXMMessageStatusTypeSeen)] = [self parseFromSpecificStateDictionary:dictionary[@"seen_by"]];
    dict[@(NXMMessageStatusTypeDelivered)] = [self parseFromSpecificStateDictionary:dictionary[@"delivered_to"]];
    
    return dict;
}

- (NSMutableDictionary<NSString *, NSDate *> *)parseFromSpecificStateDictionary:(NSDictionary *)specificStateDictionary {
    NSMutableDictionary<NSString *, NSDate *> *outputDictionary = [[NSMutableDictionary alloc] init];
    for (NSString *key in specificStateDictionary) {
        outputDictionary[key] = [NXMUtils dateFromISOString:specificStateDictionary[key]];
    }
    return outputDictionary;
}

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

@end
