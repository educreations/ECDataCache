//
//  ECDataCache.h
//  ECDataCache
//
//  Created by Chris Streeter on 2/27/13.
//  Copyright 2013 Educreations, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECDataCache : NSCache

+ (instancetype)sharedCache;

- (NSData *)dataForKey:(NSString *)key;
- (NSData *)dataForURL:(NSURL *)url;

- (void)setData:(NSData *)data forKey:(NSString *)key;
- (void)setData:(NSData *)data forURL:(NSURL *)url;

- (void)removeDataForKey:(NSString *)key;
- (void)removeDataForURL:(NSURL *)url;

@end
