//
//  NXMEnums.h
//  NexmoConversationObjC
//
//  Created by Chen Lev on 5/16/18.
//  Copyright © 2018 Vonage. All rights reserved.
//


typedef NS_ENUM(NSInteger, NXMMediaType) {
    NXMMediaTypeAudio,
    NXMMediaTypeVideo,
};

typedef NS_ENUM(NSInteger, NXMMediaStreamType) {
    NXMMediaStreamTypeNone,
    NXMMediaStreamTypeSend,
    NXMMediaStreamTypeReceive,
    NXMMediaStreamTypeSendReceive
};

typedef NS_ENUM(NSInteger, NXMEventType){
    NXMEventGeneral,
    NXMEventTypeText,
    NXMEventTypeImage,
    NXMEventTypeTextStatus,
    NXMEventTypeTextTyping,
    NXMEventTypeMedia,
    NXMEventTypeMember,
    NXMEventTypeSip
};

typedef NS_ENUM(NSInteger, NXMSipEventType){
    NXMSipEventRinging,
    NXMSipEventAnswered,
    NXMSipEventStatus,
    NXMSipEventHangup
};

typedef NS_ENUM(NSInteger, NXMEventState){
    NXMEventStateSeenBy,
    NXMEventStateDelievredTo
};

