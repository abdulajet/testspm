//
//  NXMLeg.h
//  NexmoClient
//
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMEnums.h"

@interface NXMLeg : NSObject

@property (nonatomic, copy, nullable) NSString *legId;
@property (nonatomic, assign) NXMLegType legType;
@property (nonatomic, assign) NXMLegStatus legStatus;
@property (nonatomic, copy, nullable) NSString *conversationId;
@property (nonatomic, copy, nullable) NSString *memberId;
@property (nonatomic, copy, nullable) NSDate *date;

@end

