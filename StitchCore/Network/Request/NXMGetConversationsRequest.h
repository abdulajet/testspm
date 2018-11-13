//
//  NXMGetConversationsRequest.h
//  StitchCore
//
//  Copyright © 2018 Vonage. All rights reserved.
//


#import "NXMBaseRequest.h"

@interface NXMGetConversationsRequest : NXMBaseRequest

@property (nonatomic, strong, nullable) NSString *name;
@property (nonatomic, strong, nullable) NSString *dateStart;
@property (nonatomic, strong, nullable) NSString *dateEnd;
@property (nonatomic, strong, nullable) NSString *order;
@property long pageSize;
@property long recordIndex;

@end
