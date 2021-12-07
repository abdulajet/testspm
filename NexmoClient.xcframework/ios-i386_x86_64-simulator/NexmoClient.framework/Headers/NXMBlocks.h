//
//  NXMBlocks.h
//  NexmoClient
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Success callback - Typealias for `() -> Void`
typedef void(^NXMSuccessCallback)(void);

/// Success callback with ID - Typealias for `(String?) -> Void`
typedef void(^NXMSuccessCallbackWithId)(NSString * _Nullable value);

/// Success callback with an object - Typealias for `(NSObject?) -> Void`
typedef void(^NXMSuccessCallbackWithObject)(NSObject * _Nullable object);

/// Success callback with objects - Typealias for `([Any]?) -> Void`
typedef void(^NXMSuccessCallbackWithObjects)(NSArray * _Nullable objects);

/// Error callback - Typealias for `(Error?) -> Void`
typedef void(^NXMErrorCallback)(NSError * _Nullable error);

/// Completion callback - Typealias for `(Error?) -> Void`
typedef void(^NXMCompletionCallback)(NSError * _Nullable error);
