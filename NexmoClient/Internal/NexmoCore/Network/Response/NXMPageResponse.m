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
    NSURL *first = [NSURL URLWithString:data[@"first"][@"href"]];
    NSURL *me = [NSURL URLWithString:data[@"self"][@"href"]];
    NSURL *next = [NSURL URLWithString:data[@"next"][@"href"]];
    NSURL *prev = [NSURL URLWithString:data[@"prev"][@"href"]];
    return [self initWithFirst:first andWithMe:me andWithNext:next andWithPrev:prev];
}

@end

@implementation NXMPageResponse

-(nullable instancetype)initWithPageSize:(unsigned int)pageSize
                           andWithCursor:(nonnull NSString *)cursor
                             andWithData:(nonnull NSArray *)data
                        andWithPageLinks:(NXMPageLinks *)pageLink{
    if (self = [super init]){
        self.pageSize = pageSize;
        self.cursor = cursor;
        self.data = data;
        self.links = pageLink;
    }
    return self;
}
-(nullable instancetype)initWithData:(nonnull NSDictionary*)data{
    return [self initWithPageSize:[data[@"page_size"] intValue]
                    andWithCursor:data[@"cursor"]
                      andWithData:[[data[@"_embedded"][@"data"] allValues] firstObject]
                 andWithPageLinks:[[NXMPageLinks alloc] initWithData:data[@"_links"]]];
}

@end
