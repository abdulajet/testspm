//
//  Header.h
//  NexmoClient
//
//  Created by Assaf Passal on 7/3/19.
//  Copyright © 2019 Vonage. All rights reserved.
//

#ifndef Header_h
#define Header_h
#import <Foundation/Foundation.h>

@interface NXMPageLinks : NSObject

@property (nonatomic, strong, nonnull) NSURL *first;
@property (nonatomic, strong, nonnull) NSURL *me;
@property (nonatomic, strong, nullable) NSURL *next;
@property (nonatomic, strong, nullable) NSURL *prev;

-(nullable instancetype)initWithFirst:(nonnull NSURL*)first andWithMe:(nonnull NSURL*)me andWithNext:(nullable NSURL*)next andWithPrev:(nullable NSURL*)prev;
-(nullable instancetype)initWithData:(nonnull NSDictionary*)data;

@end

@interface NXMPageResponse : NSObject

@property (nonatomic ) unsigned int pageSize;
@property (nonatomic, strong, nonnull) NSString *cursor;
@property (nonatomic, strong, nonnull) NSDictionary *data;
@property (nonatomic, strong, nonnull) NXMPageLinks* links;

-(nullable instancetype)initWithPageSize:(unsigned int)pageSize andWithCursor:(nonnull NSString*)cursor andWithData:(nonnull NSDictionary*)data andWithPageLinks:(nonnull NXMPageLinks*)pageLink;
-(nullable instancetype)initWithData:(nonnull NSDictionary*)data;
@end
#endif /* Header_h */
