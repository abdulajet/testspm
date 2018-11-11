//
//  NXMConversationEventsController.h
//  StitchObjC
//
//  Created by Iliya Barenboim on 28/08/2018.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXMConversationEventsQueue.h"
@class NXMEvent;
@class NXMConversationEventsController;
@protocol NXMConversationEventsControllerDelegate <NSObject>

typedef NS_ENUM(NSUInteger, NXMEventsControllerChangeType) {
    NXMEventsControllerChangeInsert = 1,
    NXMEventsControllerChangeDelete = 2,
    NXMEventsControllerChangeMove = 3,
    NXMEventsControllerChangeUpdate = 4
};

@optional
- (void)nxmController:(NXMConversationEventsController *_Nonnull)controller didChangeEvent:(NXMEvent*_Nonnull)anEvent atIndex:(NSUInteger)index forChangeType:(NXMEventsControllerChangeType)type newIndex:(NSUInteger)newIndex;

@optional
- (void)nxmControllerWillChangeContent:(NXMConversationEventsController *_Nonnull)controller;

@optional
- (void)nxmControllerDidChangeContent:(NXMConversationEventsController *_Nonnull)controller;

@end

@interface NXMConversationEventsController : NSObject <NXMConversationEventsQueueDelegate>

@property (nonatomic,weak) _Nullable id <NXMConversationEventsControllerDelegate> delegate;
@property (nonatomic,strong,readonly)NSArray<NXMEvent*>* _Nonnull events;

- (instancetype _Nonnull )initWithSubscribedEventsType:(NSSet*_Nonnull)eventsType delgate:(id   <NXMConversationEventsControllerDelegate>_Nullable)delegate;

@end
