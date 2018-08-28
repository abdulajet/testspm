//
//  NXMMediaActionEvent.h
//  StitchObjC
//
//  Created by Doron Biaz on 8/7/18.
//  Copyright © 2018 Vonage. All rights reserved.
//

#import "NXMEvent.h"

@interface NXMMediaActionEvent : NXMEvent
@property (nonatomic, strong, nonnull) NSString *toMemberId;
@property (nonatomic) NXMMediaType mediaType;
@property (nonatomic) NXMMediaActionType actionType;

@end
