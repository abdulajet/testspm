//
//  NXMRouter.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 3/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMRouter.h"
#import "NXMErrors.h"
#import "NXMErrorParser.h"

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
            NSError *resError = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:[NXMErrorParser parseError:data] userInfo:nil];
            responseBlock(resError, nil);
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

- (void)addUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock {
    NSDictionary *dict = @{
        @"user_id": userId,
        @"action": @"join",
        @"channel": @{
                @"type": @"app"
            }
    };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
        completionBlock(error);
    }];
}

- (void)inviteUserToConversation:(nonnull NSString *)conversationId userId:(nonnull NSString *)userId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock{
    NSDictionary *dict = @{
                           @"user_id": userId,
                           @"action": @"invite",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
        completionBlock(error);
    }];
}

- (void)joinMemberToConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock{
    NSDictionary *dict = @{
                           @"member_id": memberId,
                           @"action": @"join",
                           @"channel": @{
                                   @"type": @"app"
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members", self.baseUrl, conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
        completionBlock(error);
    }];
}

- (void)removeMemberFromConversation:(nonnull NSString *)conversationId memberId:(nonnull NSString *)memberId completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock{
    NSDictionary *dict = @{
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/members/%@", self.baseUrl, conversationId, memberId]];
    
    [self requestToServer:dict url:url httpMethod:@"DELETE" completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
        completionBlock(error);
    }];
}


- (void)sendTextToConversation:(nonnull NSString*)conversationId memberId:(nonnull NSString*)memberId textToSend:(nonnull NSString*)textTeSend completionBlock:(void (^_Nullable)(NSError * _Nullable error))completionBlock{
    NSDictionary *dict = @{
                           @"from": memberId,
                           @"type": @"text",
                           @"body": @{
                                   @"text": textTeSend
                                   }
                           };
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/conversations/%@/events", self.baseUrl, conversationId]];
    
    [self requestToServer:dict url:url httpMethod:@"POST" completionBlock:^(NSError * _Nullable error, NSString * _Nullable data) {
        completionBlock(error);
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
        
        if (((NSHTTPURLResponse *)response).statusCode != 200){
            // TODO: map code from error msg
            NSError *resError = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:[NXMErrorParser parseError:data] userInfo:nil];
            responseBlock(resError, nil);
            return;
        }
        
        
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!jsonDict || jsonError) {
            // TODO: map code from error msg
            NSError *resError = [[NSError alloc] initWithDomain:NXMStitchErrorDomain code:[NXMErrorParser parseError:data] userInfo:nil];
            responseBlock(resError, nil);
            return;
        }
        
        responseBlock(nil, jsonDict);
        
    }] resume];
}


@end
