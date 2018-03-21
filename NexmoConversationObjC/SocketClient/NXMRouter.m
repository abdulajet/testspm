//
//  NXMRouter.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMRouter.h"

@interface NXMRouter()

@property NSString *baseUrl;
@property NSString *token;


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

- (BOOL)getConversationWithId:(NSString*)convId {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversation/%@", self.baseUrl, convId]];
    [url setValue:[NSString stringWithFormat:@"bearer %@", self.token] forKey:@"Authorization"];
    [url setValue:@"application/json" forKey:@"Content-Type"];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            // TODO:
            NSLog(@"Got response %@ with error %@.\n", response, error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
    }] resume];
    
    return YES;}

- (void)createConversationWithName:(NSString *)name
                     responseBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable conversationId))responseBlock {
    NSError *jsonErr;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"display_name": name} options:0 error: &jsonErr];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations", self.baseUrl]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            responseBlock(error, nil);
            return;
        }
        
        //NXMConversation *conversation
        NSString *convId = data[@"id"];
        if (!convId) {
            // TODO: error conv failed
            responseBlock([[NSError alloc] initWithDomain:@"f" code:0 userInfo:nil], nil);
            return;
        }
        
        responseBlock(nil, convId);
        
    }];
    
}

- (void)addUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock {
    NSDictionary *dict = @{
        @"user_id": userId,
        @"action": @"join",
        @"channel": @{
                @"type": @"app"
            }
    };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    NSString* requestType = @"POST";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:completionBlock];
}

- (void)inviteUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock{
    NSDictionary *dict = @{
                           @"user_id": userId,
                           @"action": @"invite",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    NSString* requestType = @"POST";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:completionBlock];
}
- (void)joinMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock{
    NSDictionary *dict = @{
                           @"member_id": memberId,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    NSString* requestType = @"POST";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:completionBlock];
}

- (void)removeMemberFromConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock{
    NSDictionary *dict = @{
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members/%@", self.baseUrl, conversationId, memberId]];
    
    NSString* requestType = @"DELETE";
    [self requestToServer:dict url:url httpMethod:requestType completionBlock:completionBlock];
}
#pragma mark - private

- (void)requestToServer:(nonnull NSDictionary*)dict url:(nonnull NSURL*)url httpMethod:(nonnull NSString*)httpMethod completionBlock:(void (^_Nullable)(NSError * _Nullable error, NSString * _Nullable data))completionBlock{
    NSError *jsonErr;
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: &jsonErr];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [self addHeader:request];
    [request setHTTPMethod:httpMethod];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            completionBlock(error,nil);
            return;
        }
        completionBlock(nil,nil);
    }];
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
        
        if (((NSHTTPURLResponse *)response).statusCode != 200){
            NSString *responseErrMsg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *resError = [[NSError alloc] initWithDomain:@"" code:1 userInfo:nil];
            responseBlock(resError, nil);
            return;
        }
        
        
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!jsonDict || jsonError) {
            NSError *resError = [[NSError alloc] initWithDomain:@"" code:1 userInfo:nil];
            responseBlock(resError, nil);
            return;
        }
        
        responseBlock(nil, jsonDict);
        
    }] resume];
}


@end
