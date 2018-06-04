//
//  NXMRouter.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "NXMRouter.h"
#import "NXMErrors.h"
#import "NXMErrorParser.h"
#import "NXMAddUserRequest.h"
#import "NXMSendTextEventRequest.h"
#import "NXMDeleteEventRequest.h"

#import "NXMNetworkCallbacks.h"
#import "NXMMemberEvent.h"
#import "NXMMediaEvent.h"
#import "NXMTextEvent.h"
#import "NXMTextStatusEvent.h"
#import "NXMTextTypingEvent.h"
#import "NXMTextEventStatus.h"
#import "NXMImageEvent.h"

@interface NXMRouter()

@property NSString *baseUrl;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *sessionId;


@end
@implementation NXMRouter

- (nullable instancetype)initWitHost:(nonnull NSString *)host {
    if (self = [super init]) {
        self.baseUrl = host;
    }
    
    return self;
}

- (void)setToken:(NSString *)token {
    _token = token;
}

- (void)setSessionId:(nonnull NSString *)sessionId {
    _sessionId = sessionId;
}

- (BOOL)getConversationWithId:(NSString*)convId  completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMConversationDetails * _Nullable conversation))completionBlock {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@", self.baseUrl, convId]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            completionBlock(error, nil);
            return;
        }
        
        NSString *convId = @"uuid";
        NXMConversationDetails *details = [[NXMConversationDetails alloc] initWithId:convId];
        details.name = data[@"name"];
        details.created = data[@"timestamp"][@"created"];
        details.sequence_number = [data[@"sequence_number"] intValue];
        details.properties = data[@"properties"];
        
        NSMutableArray *members = [[NSMutableArray alloc] init];
        
        for (NSDictionary* memberJson in data[@"members"]) {
            NXMMember *member = [[NXMMember alloc] initWithMemberId:memberJson[@"member_id"] conversationId:convId user:memberJson[@"user_id"] name:memberJson[@"name"] state:memberJson[@"state"]];

            member.inviteDate = memberJson[@"timestamp"][@"invited"]; // TODO: NSDate
            member.joinDate = memberJson[@"timestamp"][@"joined"]; // TODO: NSDate
            member.leftDate = memberJson[@"timestamp"][@"left"]; // TODO: NSDate
            
            [members addObject:member];
        }

        completionBlock(nil, details);
    }];
    
    return YES;
}


- (void)createConversation:(nonnull NXMCreateConversationRequest*)createConversationRequest
                 onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                   onError:(ErrorCallback _Nullable)onError {
    NSError *jsonErr;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"display_name": createConversationRequest.displayName} options:0 error: &jsonErr];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@conversations", self.baseUrl]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            NSError *resError = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:[NXMErrorParser parseError:data] userInfo:nil];
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

- (void)enableMedia:(NSString *)conversationId memberId:(NSString *)memberId sdp:(NSString *)sdp mediaType:(NSString *)mediaType // TODO: enum
          onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
            onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{ @"from": memberId,
                            @"body": @{
                                @"offer": @{
                                    @"sdp": sdp,
                                    @"label": @""
                                }
                            },
                            @"originating_session": self.sessionId };
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/rtc", self.baseUrl, conversationId]];

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
           onSuccess:(SuccessCallback _Nullable)onSuccess
             onError:(ErrorCallback _Nullable)onError {
    
    NSDictionary *dict = @{ @"from": memberId, @"originating_session": self.sessionId};
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/rtc/%@", self.baseUrl, conversationId, rtcId]];

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

- (void)pauseMedia:(NSString *)conversationId mediaType:(NSString *)mediaType // TODO: enum
      completionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler {
    
}

- (void)resumeMedia:(NSString *)conversationId mediaType:(NSString *)mediaType // TODO: enum
       completionHandler:(void (^_Nullable)(NSError * _Nullable error))completionHandler {
    
}


- (void)addUserToConversation:(nonnull NXMAddUserRequest*)addUserRequest
                    onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                      onError:(ErrorCallback _Nullable)onError {

    NSDictionary *dict = @{
                           @"user_id": addUserRequest.userID,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, addUserRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}

- (void)inviteUserToConversation:(nonnull NXMInviteUserRequest *)inviteUserRequest
                       onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                         onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{
                           @"user_id": inviteUserRequest.userID,
                           @"action": @"invite",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, inviteUserRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}

- (void)joinMemberToConversation:(nonnull NXMJoinMemberRequest *)joinMembetRequest
                       onSuccess:(SuccessCallbackWithId)onSuccess
                         onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{
                           @"member_id": joinMembetRequest.memberID,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, joinMembetRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}

- (void)removeMemberFromConversation:(nonnull NXMRemoveMemberRequest *)removeMemberRequest
                           onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                             onError:(ErrorCallback _Nullable)onError{
    NSDictionary *dict = @{
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members/%@", self.baseUrl, removeMemberRequest.conversationID, removeMemberRequest.memberID]];
    
    [self requestToServer:dict url:url httpMethod:@"DELETE" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(nil); // TODO: eventId;
    }];
}

- (void)sendTextToConversation:(nonnull NXMSendTextEventRequest*)sendTextEventRequest
                     onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{
                           @"from": sendTextEventRequest.memberID,
                           @"type": @"text",
                           @"body": @{
                                   @"text": sendTextEventRequest.textToSend
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/events", self.baseUrl, sendTextEventRequest.conversationID]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        NSString *textId = data[@"id"];
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(textId); // TODO: eventId;
    }];
}

- (void)sendImage:(nonnull NXMSendImageRequest *)sendImageRequest
        onSuccess:(SuccessCallbackWithId _Nullable)onSuccess
          onError:(ErrorCallback _Nullable)onError {
    
    // set your URL Where to Upload Image
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/image/", @"https://api.nexmo.com/v1/v1"]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:[NSString stringWithFormat:@"bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *bodyDict = [NSString stringWithFormat:@"{\"from\":%@, \"type\":\"image\"}", sendImageRequest.memberId];
    
    NSString *boundary = @"10xKhTmLbOuNdArY";
    //Start of First Part
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"message\"\r\n"
                      dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/json; charset=UTF-8\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Transfer: base64\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[bodyDict dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Second Part Attachment
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attachment\"; filename=\"%@\"\r\n", @"optionalFileName"]
                      dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n",@"image/jpeg" ]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Transfer: base64\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:sendImageRequest.image];
    
    //End
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];

    
    // Get Response of Your Request
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        NSString *a = @"11";
        a = data[@"aa"];
        onSuccess(@"1");
    }];

}

- (void)deleteTextFromConversation:(nonnull NXMDeleteEventRequest*)deleteEventRequest
                         onSuccess:(SuccessCallback _Nullable)onSuccess
                           onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{
                           @"from": deleteEventRequest.memberID,
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/events/%@", self.baseUrl, deleteEventRequest.conversationID,deleteEventRequest.eventID]];
    
    NSString* requestType = @"DELETE";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            onError(error);
            return;
        }
        
        onSuccess(); // TODO: eventId;
    }];
}

- (BOOL)getConversationsPaging:( NSString* _Nullable )name dateStart:( NSString* _Nullable )dateStart  dateEnd:( NSString* _Nullable )dateEnd pageSize:(long)pageSize recordIndex:(long)recordIndex order:( NSString* _Nullable )order completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSArray<NXMConversationDetails*> * _Nullable data))completionBlock{
    NSDictionary *dict = @{
                           };
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations?%@", self.baseUrl, vars]];
    
    NSString* requestType = @"GET";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        if (data != nil){
            NSMutableArray *conversations = [[NSMutableArray alloc] init];
            for (NSDictionary* conversationJson in data[@"_embedded"][@"conversations"]){
                NXMConversationDetails *details = [NXMConversationDetails alloc];
                details.name = conversationJson[@"name"];
                details.uuid = conversationJson[@"uuid"];
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
               onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                 onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{ };
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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations?%@", self.baseUrl, vars]];
    
    NSString* requestType = @"GET";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        if (error) {
            onError(error);
            return;
        }
        
        if (!data){
            onError([[NSError alloc] initWithDomain:NXMStitchErrorDomain code:NXMStitchErrorCodeUnknown userInfo:nil]);
            return;
        }
        
        NSMutableArray *conversations = [[NSMutableArray alloc] init];
        for (NSDictionary* conversationJson in data[@"_embedded"][@"conversations"]){
            NXMConversationDetails *details = [NXMConversationDetails alloc];
            details.name = conversationJson[@"name"];
            details.uuid = conversationJson[@"uuid"];
            [conversations addObject:details];
        }
        
        NXMPageInfo *pageInfo = [[NXMPageInfo alloc] initWithCount:data[@"count"]
                                                          pageSize:data[@"page_size"]
                                                       recordIndex:data[@"record_index"]];
    
        onSuccess(conversations, pageInfo);
    }];
}
- (void)getEvents:(NXMGetEventsRequest *)getEventsRequest onSuccess:(SuccessCallbackWithEvents)onSuccess onError:(ErrorCallback)onError{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/events", self.baseUrl, getEventsRequest.conversationId]];
    NSString* requestType = @"GET";
    
    NSDictionary *body = @{};
    if (getEventsRequest.startId && getEventsRequest.endId) {
        body = @{ @"start_id": getEventsRequest.startId,
                 @"end_id": getEventsRequest.endId
                  };
    };
    
    [self requestToServer:body url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error){
            onError(error);
            return;
        }
        
        if (!data){
            onError([[NSError alloc] initWithDomain:NXMStitchErrorDomain code:NXMStitchErrorCodeUnknown userInfo:nil]);
            return;
        }
        
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for (NSDictionary* eventJson in data){
            NSString* type = eventJson[@"type"];
            if ([type isEqual:@"member:joined"]){
                [events addObject:[self parseMemberEvent:@"joined" dict:eventJson conversationId:getEventsRequest.conversationId]];
            }else if ([type isEqual:@"member:invited"]){
                [events addObject:[self parseMemberEvent:@"invited" dict:eventJson conversationId:getEventsRequest.conversationId]];
            }else if ([type isEqual:@"member:left"]){
                [events addObject:[self parseMemberEvent:@"left" dict:eventJson conversationId:getEventsRequest.conversationId]];
            }else if ([type isEqual:@"member:media"]){
                [events addObject:[self parseMediaEvent:eventJson conversationId:getEventsRequest.conversationId]];
            }else if ([type isEqual:@"text:seen"]){
                [events addObject:[self parseTextStatusEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMTextEventStatusESeen]];
            }else if ([type isEqual:@"text:delivered"]){
                [events addObject:[self parseTextStatusEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMTextEventStatusEDelivered]];
            }else if ([type isEqual:@"text"]){
                [events addObject:[self parseTextEvent:eventJson conversationId:getEventsRequest.conversationId]];
            }else if ([type isEqual:@"image"]){
                // TODO: [events addObject:event];
            }else if ([type isEqual:@"image:seen"]){
                // TODO: [events addObject:event];
            }else if ([type isEqual:@"image:delivered"]){
                //// TODO: [events addObject:event];
            }else if ([type isEqual:@"event:deleted"]){
                [events addObject:[self parseTextStatusEvent:eventJson conversationId:getEventsRequest.conversationId state:NXMTextEventStatusEDeleted]];
            }
        }
        
        onSuccess(events);
    }];
}

- (void)getConversationEvents:(NSString *)conversationId
                    onSuccess:(SuccessCallbackWithConversationDetails _Nullable)onSuccess
                      onError:(ErrorCallback _Nullable)onError { // TODO: add start and end index
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/events", self.baseUrl, conversationId]];
    NSString* requestType = @"GET";
    
    [self requestToServer:@{} url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        if (error) {
            onError(error);
            return;
        }
        
        
    }];
}

- (void)getUserConversations:(NSString *)userId
                     onSuccess:(SuccessCallbackWithConversations _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@users/%@/conversations", self.baseUrl, userId]];
    
    NSString* requestType = @"GET";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        
        if (error) {
            onError(error);
            return;
        }
        
        if (!data){
            onError([[NSError alloc] initWithDomain:NXMStitchErrorDomain code:NXMStitchErrorCodeUnknown userInfo:nil]);
            return;
        }
        NSMutableArray *items = [NSMutableArray new];

        for (NSDictionary* detailsJson in data) {
            NXMConversationDetails *detail = [[NXMConversationDetails alloc] init];
            detail.displayName = detailsJson[@"display_name"];
            detail.members = @[];
            detail.name = detailsJson[@"name"];
            detail.sequence_number = [detailsJson[@"sequence_number"] integerValue];
            detail.uuid = detailsJson[@"id"];
            
            [items addObject:detail];
        }

        onSuccess(items, nil);
    }];
}


- (void)getConversationDetails:(nonnull NSString*)conversationId
                     onSuccess:(SuccessCallbackWithConversationDetails _Nullable)onSuccess
                       onError:(ErrorCallback _Nullable)onError {
    NSDictionary *dict = @{
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@", self.baseUrl, conversationId]];
    
    NSString* requestType = @"GET";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        
        if (error) {
            onError(error);
            return;
        }
        
        if (!data){
            onError([[NSError alloc] initWithDomain:NXMStitchErrorDomain code:NXMStitchErrorCodeUnknown userInfo:nil]);
            return;
        }
        
        NSLog(@"getConversationPressed result %@",data);
        NSString *convId = @"uuid";
        NXMConversationDetails *details = [[NXMConversationDetails alloc] initWithId:convId];
        details.name = data[@"name"];
        details.created = data[@"timestamp"][@"created"];
        details.sequence_number = [data[@"sequence_number"] intValue];
        details.properties = data[@"properties"];
        details.uuid = data[@"uuid"];
        
        NSMutableArray *members = [[NSMutableArray alloc] init];
        
        for (NSDictionary* memberJson in data[@"members"]) {
            NXMMember *member = [[NXMMember alloc] initWithMemberId:memberJson[@"member_id"] conversationId:convId user:memberJson[@"user_id"] name:memberJson[@"name"] state:memberJson[@"state"]];
            
            member.inviteDate = memberJson[@"timestamp"][@"invited"]; // TODO: NSDate
            member.joinDate = memberJson[@"timestamp"][@"joined"]; // TODO: NSDate
            member.leftDate = memberJson[@"timestamp"][@"left"]; // TODO: NSDate
            
            [members addObject:member];
        }
    }];
}


- (void)getUser:(nonnull NSString*)userId
        completionBlock:(void (^_Nullable)(NSError * _Nullable error, NXMUser * _Nullable data))completionBlock{
    NSDictionary *dict = @{
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@", self.baseUrl, userId]];
    
    NSString* requestType = @"GET";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data){
        if (data != nil){
            NSLog(@"getUser result %@",data);
            NXMUser *user = [NXMUser alloc];
            user.name = data[@"name"];
            user.uuid = data[@"id"];
           
            completionBlock(nil, user);
        }
        else{
            completionBlock(error,nil);
        }
    }];
}
#pragma mark - private

- (void)requestToServer:(nonnull NSDictionary*)dict url:(nonnull NSURL*)url httpMethod:(nonnull NSString*)httpMethod completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary * _Nullable data))completionBlock{
    NSError *jsonErr;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: &jsonErr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [self addHeader:request];
    
    [request setHTTPMethod:httpMethod];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:completionBlock];
}

- (void)addHeader:(NSMutableURLRequest *)request {
    [request setValue:[NSString stringWithFormat:@"bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

- (void)executeRequest:(NSURLRequest *)request  responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSDictionary *      _Nullable data))responseBlock {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            // TODO: network error
            responseBlock(error, nil);
            NSLog(@"Got response %@ with error %@.\n", response, error);
            return;
        }
        
        // TODO: 413 Payload too lage
        if (((NSHTTPURLResponse *)response).statusCode != 200){
            // TODO: map code from error msg
            NSError *resError = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:[NXMErrorParser parseErrorWithData:data] userInfo:nil];
            responseBlock(resError, nil);
            return;
        }
        
        
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!jsonDict || jsonError) {
            // TODO: map code from error msg
            NSError *resError = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:[NXMErrorParser parseErrorWithData:data] userInfo:nil];
            responseBlock(resError, nil);
            return;
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
    return dict[@"timestamp"];
}

- (NXMMemberEvent* )parseMemberEvent:(nonnull NSString*)state dict:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId{
    NXMMemberEvent* event = [NXMMemberEvent alloc];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeMember;
    event.state = state;
    event.memberId = dict[@"body"][@"user"][@"member_id"];
    event.name = dict[@"body"][@"user"][@"name"];
    event.user = [NXMUser alloc];
    event.user.name = dict[@"body"][@"user"][@"name"];
    event.user.uuid = dict[@"body"][@"user"][@"user_id"];
    return event;
}

- (NXMMediaEvent* )parseMediaEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId{
    NXMMediaEvent* event = [NXMMediaEvent alloc];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeMedia;
    if (dict[@"body"][@"audio"]){
        event.isMediaEnabled = [dict[@"body"][@"audio"] boolValue];
    }
    else if (dict[@"body"][@"video"]){
        event.isMediaEnabled = [dict[@"body"][@"audio"] boolValue];
    }
    return event;
}

- (NXMTextStatusEvent* )parseTextStatusEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId state:(NXMTextEventStatusE )state{
    NXMTextStatusEvent * event = [NXMTextStatusEvent alloc];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeTextStatus;
    event.status = state;
    event.eventId = dict[@"body"][@"event_id"];
    
    return event;
}

- (NXMTextEvent *)parseTextEvent:(nonnull NSDictionary*)dict conversationId:(nonnull NSString*)conversationId {
    NXMTextEvent* event = [NXMTextEvent alloc];
    event.sequenceId = [[self getSequenceId:dict] integerValue];
    event.conversationId = conversationId;
    event.fromMemberId = [self getFromMemberId:dict];
    event.creationDate = [self getCreationDate:dict];
    event.type = NXMEventTypeText;
    event.text = dict[@"body"][@"text"];
    return event;
}

// TODO: state
- (NXMImageEvent *)parseImageEvent:(nonnull NSDictionary*)json conversationId:(nonnull NSString*)conversationId {
    
    NXMImageEvent *imageEvent = [[NXMImageEvent alloc] initWithConversationId:conversationId
                                                                   sequenceId:[json[@"id"] integerValue]
                                                                 fromMemberId:json[@"from"]
                                                                 creationDate:json[@"timestamp"]
                                                                         type:NXMEventTypeImage];
    NSDictionary *body = json[@"body"][@"representations"];
    imageEvent.imageId = body[@"id"];
    NSDictionary *originalJSON = body[@"original"];
    imageEvent.originalImage = [[NXMImageInfo alloc] initWithUuid:originalJSON[@"id"]
                                                             size:[originalJSON[@"size"] integerValue]
                                                              url:originalJSON[@"url"]
                                                             type:NXMImageTypeOriginal];
    
    NSDictionary *mediumJSON = body[@"medium"];
    imageEvent.mediumImage = [[NXMImageInfo alloc] initWithUuid:mediumJSON[@"id"]
                                                           size:[mediumJSON[@"size"] integerValue]
                                                            url:mediumJSON[@"url"]
                                                           type:NXMImageTypeMedium];
    
    
    NSDictionary *thumbnailJSON = body[@"thumbnail"];
    imageEvent.thumbnailImage = [[NXMImageInfo alloc] initWithUuid:thumbnailJSON[@"id"]
                                                              size:[thumbnailJSON[@"size"] integerValue]
                                                               url:thumbnailJSON[@"url"]
                                                              type:NXMImageTypeThumbnail];
    
    
    return imageEvent;
}

@end
