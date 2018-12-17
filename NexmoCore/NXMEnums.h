//
//  NXMEnums.h
//  NexmoCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXMMediaType) {
    NXMMediaTypeNone = (0),
    NXMMediaTypeAudio = (1 << 0),
    NXMMediaTypeVideo = (1 << 1)
};

typedef NS_ENUM(NSInteger, NXMMediaActionType){
    NXMMediaActionTypeSuspend
    //TODO:earmuffed?held?
};

typedef NS_ENUM(NSInteger, NXMMediaStreamType) {
    NXMMediaStreamTypeNone,
    NXMMediaStreamTypeSend,
    NXMMediaStreamTypeReceive,
    NXMMediaStreamTypeSendReceive
};

typedef NS_ENUM(NSInteger, NXMEventType){
    NXMEventTypeGeneral,
    NXMEventTypeText,
    NXMEventTypeImage,
    NXMEventTypeMessageStatus,
    NXMEventTypeTextTyping,
    NXMEventTypeMedia,
    NXMEventTypeMediaAction,
    NXMEventTypeMember,
    NXMEventTypeSip
};

typedef NS_ENUM(NSInteger, NXMSipEventType){
    NXMSipEventRinging,
    NXMSipEventAnswered,
    NXMSipEventStatus,
    NXMSipEventHangup
};

typedef NS_ENUM(NSInteger, NXMMessageStatusType) {
    NXMMessageStatusTypeNone,
    NXMMessageStatusTypeSeen,
    NXMMessageStatusTypeDelivered,
    NXMMessageStatusTypeDeleted
};

typedef NS_ENUM(NSInteger, NXMTextTypingEventStatus) {
    NXMTextTypingEventStatusOn,
    NXMTextTypingEventStatusOff
};

typedef NS_ENUM(NSInteger, NXMMemberState) {
    NXMMemberStateInvited,
    NXMMemberStateJoined,
    NXMMemberStateLeft
};
