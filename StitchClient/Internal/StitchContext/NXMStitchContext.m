//
//  NXMStitchContext.m
//  StitchClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMStitchContext.h"
#import <StitchCore/StitchCore.h>


@interface NXMStitchContext()
@property (readwrite, nonnull, nonatomic) NXMStitchCore *coreClient;
@property (readwrite, nonnull, nonatomic) NXMEventsDispatcher *eventsDispatcher;
@property (readwrite, weak, nonatomic) NSObject<NXMStitchContextDelegate> *stitchContextDelegate;

@end

@implementation NXMStitchContext

-(instancetype)initWithCoreClient:(NXMStitchCore *)coreClient{
    if(self = [super init]) {
        self.coreClient = coreClient;
        [self.coreClient setDelgate:self];
        self.eventsDispatcher = [NXMEventsDispatcher new];
    }
    return self;
}

-(NXMUser *)currentUser {
    return [self.coreClient getUser];
}

-(void)setDelegate:(NSObject<NXMStitchContextDelegate> *)stitchContextDelegate {
    self.stitchContextDelegate = stitchContextDelegate;
}

- (void)imageDelivered:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.eventsDispatcher imageDelivered:statusEvent];
}

- (void)imageRecieved:(nonnull NXMImageEvent *)imageEvent {
    [self.eventsDispatcher imageRecieved:imageEvent];
}

- (void)imageSeen:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.eventsDispatcher  imageSeen:statusEvent];
}

- (void)actionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent {
    [self.eventsDispatcher actionOnMedia:mediaActionEvent];
}

- (void)informOnMedia:(nonnull NXMMediaEvent *)mediaEvent {
    [self.eventsDispatcher informOnMedia:mediaEvent];
}

- (void)localActionOnMedia:(nonnull NXMMediaActionEvent *)mediaActionEvent {
    [self.eventsDispatcher localActionOnMedia:mediaActionEvent];
}

- (void)localInformOnMedia:(nonnull NXMMediaEvent *)mediaEvent {
    [self.eventsDispatcher localInformOnMedia:mediaEvent];
}

- (void)memberInvited:(nonnull NXMMemberEvent *)memberEvent {
    [self.eventsDispatcher memberInvited:memberEvent];
}

- (void)memberJoined:(nonnull NXMMemberEvent *)memberEvent {
    [self.eventsDispatcher memberJoined:memberEvent];
}

- (void)memberRemoved:(nonnull NXMMemberEvent *)memberEvent {
    [self.eventsDispatcher memberRemoved:memberEvent];
}

- (void)messageDeleted:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.eventsDispatcher messageDeleted:statusEvent];
}

- (void)sipAnswered:(nonnull NXMSipEvent *)sipEvent {
    [self.eventsDispatcher sipAnswered:sipEvent];
}

- (void)sipHangup:(nonnull NXMSipEvent *)sipEvent {
    [self.eventsDispatcher sipHangup:sipEvent];
}

- (void)sipRinging:(nonnull NXMSipEvent *)sipEvent {
    [self.eventsDispatcher sipRinging:sipEvent];
}

- (void)sipStatus:(nonnull NXMSipEvent *)sipEvent {
    [self.eventsDispatcher sipStatus:sipEvent];
}

- (void)textDelivered:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.eventsDispatcher textDelivered:statusEvent];
}

- (void)textRecieved:(nonnull NXMTextEvent *)textEvent {
    [self.eventsDispatcher textRecieved:textEvent];
}

- (void)textSeen:(nonnull NXMMessageStatusEvent *)statusEvent {
    [self.eventsDispatcher textSeen:statusEvent];
}

- (void)textTypingOff:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self.eventsDispatcher textTypingOff:textTypingEvent];
}

- (void)textTypingOn:(nonnull NXMTextTypingEvent *)textTypingEvent {
    [self.eventsDispatcher textTypingOn:textTypingEvent];
}

- (void)connectionStatusChanged:(BOOL)isOnline {
    [self.eventsDispatcher connectionStatusChanged:isOnline];
    [self.stitchContextDelegate connectionStatusChanged:isOnline];
}

- (void)loginStatusChanged:(nullable NXMUser *)user loginStatus:(BOOL)isLoggedIn withError:(nullable NSError *)error {
    [self.eventsDispatcher loginStatusChanged:user loginStatus:isLoggedIn withError:error];
    [self.stitchContextDelegate loginStatusChanged:user loginStatus:isLoggedIn withError:error];
}

@end
