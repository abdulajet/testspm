//
//  RTCMediaWrapper.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/23/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "RTCMediaWrapper.h"

#import "MRTCMedia.h"

@interface RTCMediaWrapper()
@property MRTCMediaManager *mrtcMedia;
@property (nonatomic) id<RTCMediaWrapperDelegate> delegate;
//@property id<MRTCMediaNetwork> network;

@end


@implementation RTCMediaWrapper

//- (void)setNetworkDelegate:(id<MRTCMediaNetwork>)networkDelegate {
//    self.network = networkDelegate;
//}

- (instancetype)init {
    if (self = [super init]) {
       // self.mrtcMedia = [[MRTCMedia alloc] init];
    }
    
    return self;
}

- (void)setDelegate:(id<RTCMediaWrapperDelegate>)delegate {
    self.delegate = delegate;
}


- (void)disableMedia:(NSString *)mediaId {
    
}

- (void)enableMediaWithMediaID:(NSString *)conversationId
                      memberId:(NSString *)memberId
                  andWithAudio:(NXMMediaStreamType)audiostream
                  andWithVideo:(NXMMediaStreamType)videoStream {
    
    MRTCMediaInfo *info = [MRTCMediaInfo new];
    info._conversationId = conversationId;
    info._mediaId = conversationId;
    info._memberId = memberId;
    
    [self.mrtcMedia enableMediaWithMediaID:info
                              andWithAudio:[self nxmStreamTypeToMRTCStreamType:audiostream]
                              andWithVideo:[self nxmStreamTypeToMRTCStreamType:videoStream]];
}

- (void)answerWithMediaId:(NSString *)mediaId andSDP:(NSString *)sdp {
    [self.mrtcMedia answerWithMediaId:mediaId andSDP:sdp];
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

#pragma mark: - MRTCMediaDelegate

- (void)onMediaStatusChange:(NSString *)status mediaId:(NSString *)mediaId {
    [self.delegate onMediaStatusChangedWithConversationId:mediaId andStatus:status];
}

- (void)sendSDP:(NSString *)sdp andMediaInfo:(MRTCMediaInfo *)mediaInfo andCompletionHandler:(void (^)(NSError *))completionHandler {
    
}

@end
