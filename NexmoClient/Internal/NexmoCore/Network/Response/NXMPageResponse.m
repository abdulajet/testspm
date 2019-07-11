//
//  NXMPageResponse.m
//  NexmoClient
//
//  Created by Assaf Passal on 7/3/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMPageResponse.h"
@implementation NXMPageLinks

-(nullable instancetype)initWithFirst:(nonnull NSURL*)first andWithMe:(nonnull NSURL*)me andWithNext:(nullable NSURL*)next andWithPrev:(nullable NSURL*)prev{
    if (self = [super init]){
        self.first = first;
        self.me = me;
        self.next = next;
        self.prev = prev;
    }
    return self;
}

-(nullable instancetype)initWithData:(nonnull NSDictionary*)data{
    return [self initWithFirst:data[@"first"] andWithMe:data[@"self"] andWithNext:data[@"next"] andWithPrev:data[@"prev"]];
}

@end
@implementation NXMPageResponse

-(nullable instancetype)initWithPageSize:(unsigned int)pageSize andWithCursor:(nonnull NSString*)cursor andWithData:(nonnull NSDictionary*)data andWithPageLinks:(NXMPageLinks*)pageLink{
    if (self = [super init]){
        self.pageSize = pageSize;
        self.cursor = cursor;
        self.data = data;
        self.links = pageLink;
    }
    return self;
}
-(nullable instancetype)initWithData:(nonnull NSDictionary*)data{
    return [self initWithPageSize:[data[@"page_size"] intValue] andWithCursor:data[@"cursor"] andWithData:[[data[@"_embedded"] allValues] firstObject][@"data"] andWithPageLinks:[[NXMPageLinks alloc] initWithData:data[@"_links"]]];
}

@end
