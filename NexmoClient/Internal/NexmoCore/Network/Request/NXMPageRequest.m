//
//  NXMPageRequest.m
//  NexmoClient
//
//  Created by Assaf Passal on 7/2/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#import "NXMPageRequest.h"

@implementation NXMPageRequest

unsigned int kDefaultPageRequestSize = 20;

- (nullable instancetype)initWithPageSize:(unsigned int) pageSize withUrl:(nonnull NSURL *)url withCursor:(nullable NSString*)cursor withOrder:(nullable NSString *)order withFilter:(NSString * _Nullable)filter withFilterName:(NSString * _Nullable)filterName{
    if(self = [super init]) {
        self.pageSize = pageSize;
        self.url = url;
        self.cursor = cursor;
        self.order = order;
        self.filter = filter;
        self.filterName = filterName;
    }
    return self;
}

- (nullable instancetype)initWithUrl:(nonnull NSURL *)url withCursor:(nullable NSString*)cursor withOrder:(nullable NSString *)order{
    return [self initWithPageSize:kDefaultPageRequestSize withUrl:url withCursor:cursor withOrder:order withFilter:nil withFilterName:nil];
}

@end
