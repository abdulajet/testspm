//
//  RTCMediaWrapper.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/23/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "RTCMediaWrapper.h"

//#import "MRTCMedia.h"

@interface RTCMediaWrapper()
@property MRTCMediaManager *mrtcMedia;
@property (nonatomic) id<RTCMediaWrapperDelegate> delegate;
//@property id<MRTCMediaNetwork> network;
@property NSString* lastMemberId; // TODO: remove temporary for test
@end


@implementation RTCMediaWrapper

//- (void)setNetworkDelegate:(id<MRTCMediaNetwork>)networkDelegate {
//    self.network = networkDelegate;
//}

- (instancetype)init {
    if (self = [super init]) {
        self.mrtcMedia = [[MRTCMediaManager alloc] initWith:self];
        [self.mrtcMedia setDelegate:self];
    }
    
    return self;
}

- (void)setDelegate:(id<RTCMediaWrapperDelegate>)delegate {
    _delegate = delegate;
}


- (void)disableMedia:(NSString *)mediaId {
    
}

- (void)enableMediaWithMediaID:(NSString *)conversationId
                      memberId:(NSString *)memberId
                  andWithAudio:(NXMMediaStreamType)audiostream
                  andWithVideo:(NXMMediaStreamType)videoStream {
    
    self.lastMemberId = memberId;

    MRTCMediaInfo *mediaInfo = [[MRTCMediaInfo alloc]initWithConversation:conversationId andWithMember:memberId];
    [self.mrtcMedia enableMediaWithMediaInfo:mediaInfo andWithAudio:MRTCMediaManagerRTPStramType_SendReceive andWithVideo:MRTCMediaManagerRTPStramType_None];
}

- (void)answerWithMediaId:(NSString *)mediaId convId:(NSString *)convId andSDP:(NSString *)sdp {
    MRTCMediaInfo *mediaInfo = [[MRTCMediaInfo alloc]initWithConversation:convId andWithMember:self.lastMemberId];

    [self.mrtcMedia answerWithMediaInfo:mediaInfo andSDP:sdp andRtcId:@"22"]; // TODO: check mediaId
}



#pragma mark: - private

- (MRTCMediaManagerRTPStramType)nxmStreamTypeToMRTCStreamType:(NXMMediaStreamType)streamType {
    switch (streamType) {
        case NXMMediaStreamTypeNone:
            return MRTCMediaManagerRTPStramType_None;
        case NXMMediaStreamTypeSend:
            return MRTCMediaManagerRTPStramType_Send;
        case NXMMediaStreamTypeReceive:
            return MRTCMediaManagerRTPStramType_Receive;
        case NXMMediaStreamTypeSendReceive:
            return MRTCMediaManagerRTPStramType_SendReceive;
        default:
            return MRTCMediaManagerRTPStramType_None;
            break;
    }
}


//- (void)addMemberWithMediaId:(NSString *)mediaId andSdp:(NSString *)sdp {
//
//}
//
//- (void)updateMediaMediaId:(NSString *)mediaId andWithAudio:(RTPStreamType)audioStream andWithVideo:(RTPStreamType)videoStream {
//
//}
//
//- (void)holdWithMediaId:(NSString *)mediaId {
//
//}
//
//- (void)suspendMediaId:(NSString *)mediaId andNedia:(MediaType)type{
//
//}
//
//- (void)resumeMediaId:(NSString *)mediaId andNedia:(MediaType)type {
//
//}

#pragma mark: - MRTCMediaNetwork

- (void)sendSDP:(NSString*)sdp andMediaInfo:(MRTCMediaInfo*)mediaInfo andType:(MRTCMediaNetworkSdpType)type andComplitionHandler:(void (^)(NSString *, NSError *))completionHandler {
    
    [self.delegate sendSDP:sdp andMediaInfo:mediaInfo andCompletionHandler:^(NSError * error) {
        completionHandler(@"22", error); // TODO: add mediaId
    }];
}

- (void)terminateRtcId:(NSString*)rtcId andMediaInfo:(MRTCMediaInfo*)mediaInfo andComplitionHandler:(void (^)(NSError *))completionHandler {
    
}

#pragma mark: - MRTCMediaManagerDelegate
- (void)onMediaStatusChange:(NSString *)status {
    
}

@end
