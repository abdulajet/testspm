//
//  RTCMediaWrapper.m
//  NexmoConversationObjC
//
//  Created by Chen Lev on 4/23/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "RTCMediaWrapper.h"
#import "NXMLogger.h"

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
    [self.mrtcMedia disableMediaWithMediaId:mediaId];
}

- (void)enableMediaWithMediaID:(NSString *)conversationId
                      memberId:(NSString *)memberId
                  andWithAudio:(NXMMediaStreamType)audiostream
                  andWithVideo:(NXMMediaStreamType)videoStream {
    
    self.lastMemberId = memberId;

    MRTCMediaInfo *mediaInfo = [[MRTCMediaInfo alloc]initWithMediaId:conversationId conversationId:conversationId member:memberId];
    [self.mrtcMedia enableMediaWithMediaInfo:mediaInfo andWithAudio:MRTCMediaRTPStreamTypeSendReceive andWithVideo:MRTCMediaRTPStreamTypeNone];
}

- (void)answerWithMediaId:(NSString *)mediaId convId:(NSString *)convId andSDP:(NSString *)sdp {

    [self.mrtcMedia answerWithMediaId:convId andSDP:sdp andRtcId:mediaId];
}

- (NXMErrorCode)suspendMediaWithMediaId:(nonnull NSString *)conversationId andMediaType:(NXMMediaType)type {
    MRTCMediaType mrtcMediaType = [self mrtcMediaTypeWithNXMMediaType:type];
    if(mrtcMediaType == MRTCMediaTypeNone) {
        [NXMLogger warningWithFormat:@"NXMMediaType [%li] is not supported", (long)type];
        return NXMErrorCodeMediaNotSupported;
    }
    [self.mrtcMedia suspendMediaWithMediaId:conversationId andMediaType:mrtcMediaType];
    return NXMErrorCodeNone;
}

- (NXMErrorCode)resumeMediaWithMediaId:(nonnull NSString *)conversationId andMediaType:(NXMMediaType)type {
    MRTCMediaType mrtcMediaType = [self mrtcMediaTypeWithNXMMediaType:type];
    if(mrtcMediaType == MRTCMediaTypeNone) {
        [NXMLogger warningWithFormat:@"NXMMediaType [%li] is not supported", (long)type];
        return NXMErrorCodeMediaNotSupported;
    }
    [self.mrtcMedia resumeMediaWithMediaId:conversationId andMediaType:mrtcMediaType];
    return NXMErrorCodeNone;
}


- (NXMErrorCode)sendDTMFWithDigits:(nonnull NSString*)digits
                      andConversationId:(nonnull NSString*)conversationId
                            andMemberId:(nonnull NSString*)memberId
                            andDuration:(int) duration
                                 andGap:(int) gap{
    [self.mrtcMedia sendDTMFDigitsWithMediaId:conversationId andDigits:digits andDuration:duration andGap:gap];
    return NXMErrorCodeNone;
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

-(NXMMediaType)nxmMediaTypeWithMRTCMediaType:(MRTCMediaType)mediaType {
    switch (mediaType) {
        case MRTCMediaTypeAudio:
            return NXMMediaTypeAudio;
            break;
        case MRTCMediaTypeVideo:
            return NXMMediaTypeVideo;
            break;
        default:
            return NXMMediaTypeNone;
            break;
    }
}

-(MRTCMediaType)mrtcMediaTypeWithNXMMediaType:(NXMMediaType)mediaType {
    switch (mediaType) {
        case NXMMediaTypeAudio:
            return MRTCMediaTypeAudio;
            break;
        case NXMMediaTypeVideo:
            return MRTCMediaTypeVideo;
            break;
        default:
            return MRTCMediaTypeNone;
            break;
    }
}

-(NXMMediaInfo *)nxmMediaInfoWithMRTCMediaInfo:(MRTCMediaInfo *)mrtcMediaInfo andRtcId:(NSString *)rtcId {
    return [[NXMMediaInfo alloc] initWithMediaId:mrtcMediaInfo._mediaId conversationId:mrtcMediaInfo._conversationId rtcId:rtcId memberId:mrtcMediaInfo._memberId];
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


#pragma mark: - MRTCMediaManagerDelegate

- (void)onMediaStatusChange:(NSString *)status andMediaInfo:(MRTCMediaInfo*)mediaInfo {
    
}

- (void)sendSDP:(NSString*)sdp andMediaInfo:(MRTCMediaInfo *)mediaInfo andType:(MRTCMediaNetworkSdpType)type completionHandler:(void (^)(NSString *, NSError *))completionHandler {
    [self.delegate sendSDP:sdp andMediaInfo:mediaInfo onSuccess:^(NSString * _Nullable value) {
        completionHandler(value, nil);
    } onError:^(NSError * _Nullable error) {
        completionHandler(nil, error);
    }];
}

- (void)terminateRtcIdWithMediaInfo:(MRTCMediaInfo *)mediaInfo rtcId:(NSString *)rtcId  completionHandler:(void (^)(NSError *))completionHandler {
    [self.delegate terminateRtc:mediaInfo rtcId:rtcId completionHandler:^(NSError * error) {
        completionHandler(error);
    }];
}

- (void)onMuteStateChanged: (NSString *)rtcId andMediaInfo:(MRTCMediaInfo *)mediaInfo andIsMute:(bool)isMute andMediaType:(MRTCMediaType *)mediaType {
    [self.delegate didMuteStateChangeWithMediaInfo:[self nxmMediaInfoWithMRTCMediaInfo:mediaInfo andRtcId:rtcId]
                                         andIsMute:isMute
                                      andMediaType:[self nxmMediaTypeWithMRTCMediaType:(MRTCMediaType)mediaType]];
}

- (void)sendMuteState:(const NSString *)rtcId andMediaInfo:(MRTCMediaInfo *)mediaInfo andIsMute:(bool)isMute andMediaType:(MRTCMediaType *)mediaType completionHandler:(void (^)(bool))completionHandler {
    NXMMediaType nxmMediaType = [self nxmMediaTypeWithMRTCMediaType:(MRTCMediaType)mediaType];
    if(nxmMediaType == NXMMediaTypeNone) {
        [NXMLogger warningWithFormat:@"MRTCMediaType [%li] is not supported", (long)(MRTCMediaType)mediaType];
        completionHandler(false);
        return;
    }
    
    [self.delegate sendMuteStateWithMediaInfo:[self nxmMediaInfoWithMRTCMediaInfo:mediaInfo
                                                                         andRtcId:(NSString *)rtcId]
                                                                        andIsMute:isMute
                                                                     andMediaType:nxmMediaType
                                                                        onSuccess:^(void) {
                                                                            completionHandler(true);
                                                                        } onError:^(NSError * _Nullable error) {
                                                                            [NXMLogger errorWithFormat:@"Error sending mute with error:  %@",error];
                                                                            completionHandler(false);
                                                                        }];
}

- (void)sendDTMFCallback:(NSString *)streamId andDigit:(NSString *)digit {
    //TODOs 
}

- (void)onEarmuffStateChanged:(NSString *)rtcId andMediaInfo:(MRTCMediaInfo *)mediaInfo andIsEarmuff:(bool)isEarmuff andCallMediaType:(MRTCMediaType *)callMediaType {
    
}


- (void)onHoldStateChanged:(NSString *)rtcId andMediaInfo:(MRTCMediaInfo *)mediaInfo andIsHold:(bool)isHold andCallMediaType:(MRTCMediaType *)callMediaType {
    
}


- (void)sendHoldState:(const NSString *)rtcId andSdp:(const NSString *)sdp andMediaInfo:(MRTCMediaInfo *)mediaInfo andIsHold:(bool)isHold andCallMediaType:(MRTCMediaType *)callMediaType andCompletionHandler:(void (^)(bool))completionHandler {
    
}



@end
