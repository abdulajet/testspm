//
//  NXMStitch.m
//  StitchObjC
//
//  Created by Doron Biaz on 9/6/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMStitchClient.h"
#import "NXMStitchContext.h"
#import "NXMLogger.h"
#import "NXMConversationPrivate.h"

@interface NXMStitchClient()

@property (readwrite, weak, nonatomic) NSObject<NXMStitchClientDelegate> *delegate;
@property (nonatomic, nonnull) NXMStitchContext *stitchContext;

-(instancetype)initWithStitchContext:(NXMStitchContext *)stitchContext;
@end

@implementation NXMStitchClient
+(NXMStitchClient *)sharedInstance {
    static NXMStitchClient *_sharedStitchClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NXMStitchContext *stitchContext = [[NXMStitchContext alloc] initWithCoreClient:[NXMConversationCore new]];
        _sharedStitchClient = [[NXMStitchClient alloc] initWithStitchContext:stitchContext];
    });
    return _sharedStitchClient;
}

- (instancetype)init {
    NXMStitchContext *stitchContext = [[NXMStitchContext alloc] initWithCoreClient:[NXMConversationCore new]];
    return [self initWithStitchContext:stitchContext];
}

-(instancetype)initWithStitchContext:(NXMStitchContext *)stitchContext {
    self = [super init];
    if (self) {
        self.stitchContext = stitchContext;
        [self.stitchContext setDelegate:self];
    }
    return self;
}

#pragma mark - login and connectivity

-(BOOL)isLoggedIn {
    return self.stitchContext.coreClient.isLoggedIn;
}

-(BOOL)isConnected {
    return self.stitchContext.coreClient.isConnected;
}

-(NXMUser *)getUser {
    return  [self.stitchContext.coreClient getUser];
}

-(NSString *)getToken {
    return [self.stitchContext.coreClient getToken];
}

-(void)loginWithAuthToken:(nonnull NSString *)authToken {
    if(!self.delegate) {
        [NXMLogger warning:@"NXTStitchClient: login called without setting stitch delegate"];
    }
    [self.stitchContext.coreClient loginWithAuthToken:authToken];
}

-(void)updateAuthToken:(nonnull NSString *)authToken {
    //TODO: 🐣
}

-(void)logout {
    [self.stitchContext.coreClient logout];
}

-(void)setDelegate:(nonnull NSObject<NXMStitchClientDelegate> *)delegate {
    self.delegate = delegate;
}

- (void)connectionStatusChanged:(BOOL)isOnline {
    [self.delegate connectionStatusChanged:isOnline];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    [self.delegate loginStatusChanged:user loginStatus:isLoggedIn withError:error];
}

#pragma mark - conversation
-(void)getConversationWithId:(nonnull NSString *)converesationId completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion {
    [self.stitchContext.coreClient getConversationDetails:converesationId
                                                onSuccess:^(NXMConversationDetails * _Nullable conversationDetails) {
                                                    if(completion) {
                                                        NXMConversation *conversation = [[NXMConversation alloc] initWithConversationDetails:conversationDetails andStitchContext:self.stitchContext];
                                                        completion(nil, conversation);
                                                    }
                                                }
                                                  onError:^(NSError * _Nullable error) {
                                                      if(completion) {
                                                          completion(error, nil);
                                                      }
                                                  }];
}

-(void)createConversationWithName:(nonnull NSString *)name completion:(void(^_Nullable)(NSError * _Nullable error, NXMConversation * _Nullable conversation))completion {
    __weak NXMStitchClient *weakSelf = self;
    [self.stitchContext.coreClient createConversationWithName:name
                                                    onSuccess:^(NSString * _Nullable value) {
                                                        if(completion) {
                                                            [weakSelf getConversationWithId:value completion:^(NSError * _Nullable error, NXMConversation * _Nullable conversation){
                                                                if(error) {
                                                                    NSError *wrappingError = [NXMErrors nxmStitchErrorWithErrorCode:NXMStitchErrorCodeConversationRetrievalFailed andUserInfo:@{NSUnderlyingErrorKey: error}];
                                                                    completion(wrappingError, nil);
                                                                } else {
                                                                    completion(nil, conversation);
                                                                }
                                                            }];
                                                        }
                                                    }
                                                      onError:^(NSError * _Nullable error) {
                                                          if(completion) {
                                                              completion(error, nil);
                                                          }
                                                      }];
}
@end
