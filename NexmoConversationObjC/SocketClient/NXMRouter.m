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
        
//        [self addMemberToConversation:convId memberId:@"USR-0e364e72-d343-42bd-9a12-024518a88896" responseBlock:^(NSError * _Nullable error) {
//            if (error) {
//                // TODO: add me failed
//                responseBlock([[NSError alloc] initWithDomain:@"f" code:0 userInfo:nil], convId);
//                return;
//            }
//
//            responseBlock(nil, convId);
//        }];
    }];
}

- (void)addMemberToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock {
    
    NSError *jsonErr;
    NSDictionary *dict = @{
        @"user_id": userId,
        @"action": @"join",
        @"channel": @{
                @"type": @"app"
            }
    };
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: &jsonErr];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            completionBlock(error);
            return;
        }
        
//        NSString *state = data[@"state"];
//        NSString *memId = data[@"id"];
//        NSString *joinDate = data[@"timestamp"][@"joined"]; // TODO: date
//        NSString *usrId = data[@"user_id"];
//        // TODO: missing name
//
//        NXMMember *member = [[NXMMember alloc] initWithMemberId:memId conversationId:conversationId joinDate:joinDate userId:usrId name:@"temp" state:state];

        completionBlock(nil);
    }];
}

- (void)inviteMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock{
   
    NSError *jsonErr;
    NSDictionary *dict = @{
                           @"member_id": memberId,
                           @"action": @"invite",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: &jsonErr];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            completionBlock(error);
            return;
        }
        completionBlock(nil);
    }];
}
- (void)joinMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock{
    
    NSError *jsonErr;
    NSDictionary *dict = @{
                           @"member_id": memberId,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: &jsonErr];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            completionBlock(error);
            return;
        }
        completionBlock(nil);
    }];
}
- (void)removeMemberFromConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock{
    
    NSError *jsonErr;
    NSDictionary *dict = @{
//                           @"conv_id":conversationId,
//                           @"member_id": memberId
                           };
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error: &jsonErr];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members/%@", self.baseUrl, conversationId, memberId]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [self addHeader:request];
    [request setHTTPMethod:@"DELETE"];
    [request setHTTPBody:jsonData];
    
    [self executeRequest:request responseBlock:^(NSError * _Nullable error, NSDictionary * _Nullable data) {
        if (error) {
            completionBlock(error);
            return;
        }
        completionBlock(nil);
    }];
}
#pragma mark - private

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
