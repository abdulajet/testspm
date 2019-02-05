//
//  NXMEventsQueueDelegateHelper.h
//  NexmoClientTests
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NXMConversationEventsQueue.h"

@interface NXMEventsQueueDelegateHelper : NSObject <NXMConversationEventsQueueDelegate>
@property NSMutableArray<NXMEvent *> *handledEvents;
@property XCTestExpectation *eventHandleExpectation;
@property XCTestExpectation *finishHandleExpectation;
@property (readonly) NSArray<XCTestExpectation *> *expectations;
- (instancetype)initWithEventHandleExpectation:(XCTestExpectation *)eventHandleExpectation;
- (instancetype)initWithFinishHandleExpectation:(XCTestExpectation *)finishHandleExpectation;
- (instancetype)initWithEventHandleExpectation:(XCTestExpectation *)eventHandleExpectation andFinishHandleExpectation:(XCTestExpectation *)finishHandleExpectation;
- (NSArray<NSNumber *> *)handledEventsIds;

+ (instancetype)SingleEventHelperWithExpectationDescription:(NSString *)expectationDescription;
+ (instancetype)multiEventHelperWithExpectedNumberOfHandledEvents:(NSUInteger)expectedNumberOfHandledEvents andExpectationDescription:(NSString *)expectationDescription;
@end

