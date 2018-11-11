//
//  NXMBlocks.h
//  StitchCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessCallback)(void);
typedef void(^SuccessCallbackWithId)(NSString * _Nullable value);
typedef void(^SuccessCallbackWithObject)(NSObject * _Nullable object);
typedef void(^SuccessCallbackWithObjects)(NSArray * _Nullable objects);
typedef void(^ErrorCallback)(NSError * _Nullable error);
