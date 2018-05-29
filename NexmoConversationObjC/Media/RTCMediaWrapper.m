//
//  RTCMediaWrapper.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/23/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "RTCMediaWrapper.h"


@interface RTCMediaWrapper()
@property MRTCMedia *mrtcMedia;
@property (nonatomic) id<RTCMediaWrapperDelegate> delegate;
@property NSString* lastMemberId; // TODO: remove temporary for test
@end


@implementation RTCMediaWrapper

//- (void)setNetworkDelegate:(id<MRTCMediaNetwork>)networkDelegate {
//    self.network = networkDelegate;
//}

- (instancetype)init {
    if (self = [super init]) {
        self.mrtcMedia = [MRTCMedia new];
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
    [self.mrtcMedia enableMediaWithMediaInfo:mediaInfo andWithAudio:MRTCMediaRTPStreamTypeSendReceive andWithVideo:MRTCMediaRTPStreamTypeNone];
}

- (void)answerWithMediaId:(NSString *)mediaId convId:(NSString *)convId andSDP:(NSString *)sdp {
    MRTCMediaInfo *mediaInfo = [[MRTCMediaInfo alloc]initWithConversation:convId andWithMember:self.lastMemberId];

    [self.mrtcMedia answerWithMediaInfo:mediaInfo andSDP:sdp andRtcId:@"22"]; // TODO: check mediaId
}



#pragma mark: - private

- (MRTCMediaRTPStreamType)nxmStreamTypeToMRTCStreamType:(NXMMediaStreamType)streamType {
    switch (streamType) {
        case NXMMediaStreamTypeNone:
            return MRTCMediaRTPStreamTypeNone;
        case NXMMediaStreamTypeSend:
            return MRTCMediaRTPStreamTypeSend;
        case NXMMediaStreamTypeReceive:
            return MRTCMediaRTPStreamTypeReceive;
        case NXMMediaStreamTypeSendReceive:
            return MRTCMediaRTPStreamTypeSendReceive;
        default:
            return MRTCMediaRTPStreamTypeNone;
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


#pragma mark: - MRTCMediaManagerDelegate

- (void)onMediaStatusChange:(NSString *)status andMediaInfo:(MRTCMediaInfo *)mediaInfo {
    
}

- (void)sendSDP:(NSString *)sdp andMediaInfo:(MRTCMediaInfo *)mediaInfo andType:(MRTCMediaNetworkSdpType)type completionHandler:(void (^)(NSString *, NSError *))completionHandler {
        
        [self.delegate sendSDP:sdp andMediaInfo:mediaInfo andCompletionHandler:^(NSError * error) {
            completionHandler(@"22", error); // TODO: add mediaId
        }];
}

- (void)terminateRtcIdWithMediaInfo:(MRTCMediaInfo *)mediaInfo rtcId:(NSString *)rtcId completionHandler:(void (^)(NSError *))completionHandler {
    
}

@end
