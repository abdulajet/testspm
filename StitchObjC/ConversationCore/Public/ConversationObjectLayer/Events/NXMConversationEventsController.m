//
//  NXMConversationEventsController.m
//  StitchObjC
//
//  Created by Iliya Barenboim on 28/08/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMConversationEventsController.h"
#import "NXMConversationEventsQueue.h"
#import "NXMEvent.h"
#import "NXMMessageEvent.h"
#import "NXMMessageStatusEvent.h"
@interface NXMConversationEventsController()<NXMConversationEventsQueueDelegate>
@property (nonatomic,strong)NSMutableArray<NXMEvent*>* mutableEventsArray;
@property (nonatomic,strong)NSMutableDictionary<NSNumber*,NXMEvent*>*eventsDict;
@property (nonatomic)BOOL changingContent;
@property (nonatomic,strong)NSSet <NSNumber*>*subscribedEventsType;
@end

@implementation NXMConversationEventsController

- (instancetype)initWithSubscribedEventsType:(NSSet*)eventsType delgate:(id <NXMConversationEventsControllerDelegate>)delegate{
    self = [super init];
    if(self){
        self.subscribedEventsType = eventsType;
        self.delegate = delegate;
        self.mutableEventsArray = [[NSMutableArray alloc] init];
        self.eventsDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (NSArray<NXMEvent*>*)events{
    return self.mutableEventsArray;
}
#pragma mark - NXMConversationEventsQueueDelegate

- (void)handleEvent:(NXMEvent*_Nonnull)event{
    if(![self.subscribedEventsType containsObject:@(event.type)]){
        return;
    }

    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleEvent:event];
        });
        return;
    }
    switch (event.type) {
        case NXMEventGeneral:
            break;
        case NXMEventTypeText:
        case NXMEventTypeImage:
        case NXMEventTypeTextTyping:
        case NXMEventTypeMedia:
        case NXMEventTypeMember:
        case NXMEventTypeSip:
            [self handleInsertEvent:event];
            break;
        case NXMEventTypeMessageStatus:
            [self handleStatusEvent:(NXMMessageStatusEvent*)event];
            break;
        default:
            break;
    }
}
- (void)handleInsertEvent:(NXMEvent*)event{
    if(self.eventsDict[@(event.sequenceId)]){
        return;
    }
    if(!self.changingContent){
        self.changingContent = YES;
        if([self.delegate respondsToSelector:@selector(nxmControllerWillChangeContent:)]){
            [self.delegate nxmControllerWillChangeContent:self];
        }
    }
    self.eventsDict[@(event.sequenceId)] = event;
    [self.mutableEventsArray addObject:event];
    
    if([self.delegate respondsToSelector:@selector(nxmController:didChangeEvent:atIndex:forChangeType:newIndex:)]){
        NSUInteger newIndex = [self.mutableEventsArray indexOfObject:event];
        [self.delegate nxmController:self didChangeEvent:event atIndex:newIndex forChangeType:NXMEventsControllerChangeInsert newIndex:newIndex];
    }
    
    
}
- (void)handleStatusEvent:(NXMMessageStatusEvent *)statusEvent{
    NXMMessageEvent *updatedEvent = (NXMMessageEvent *)self.eventsDict[@(statusEvent.eventId)];
    if(!updatedEvent || ![updatedEvent isKindOfClass:NXMMessageEvent.class]){
        return;
    }
    if(!updatedEvent.state[@(statusEvent.status)]){
        updatedEvent.state[@(statusEvent.status)] = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *membersDict = updatedEvent.state[@(statusEvent.status)];
    if(membersDict[statusEvent.fromMemberId]){
        return;
    }
    
    if(!self.changingContent){
        self.changingContent = YES;
        if([self.delegate respondsToSelector:@selector(nxmControllerWillChangeContent:)]){
            [self.delegate nxmControllerWillChangeContent:self];
        }
    }
    
    membersDict[statusEvent.fromMemberId] = statusEvent.creationDate;
    if([self.delegate respondsToSelector:@selector(nxmController:didChangeEvent:atIndex:forChangeType:newIndex:)]){
        NSUInteger newIndex = [self.mutableEventsArray indexOfObject:updatedEvent];
        [self.delegate nxmController:self didChangeEvent:updatedEvent atIndex:newIndex forChangeType:NXMEventsControllerChangeUpdate newIndex:newIndex];
    }

}

- (void)finishHandleEventsSequence{
    if(![NSThread isMainThread]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishHandleEventsSequence];
        });
        return;
    }
    if(self.changingContent){
        self.changingContent = NO;
        if([self.delegate respondsToSelector:@selector(nxmControllerDidChangeContent:)]){
            [self.delegate nxmControllerDidChangeContent:self];
        }
    }
}
@end
