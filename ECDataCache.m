//
//  ECDataCache.m
//  ECDataCache
//
//  Created by Chris Streeter on 2/27/13.
//  Copyright 2013 Educreations, Inc. All rights reserved.
//

#import "ECDataCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ECDataCacheMD5)

- (NSString *)ec_MD5
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, data.length, md5Buffer);

    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }

    return output;
}

@end


@implementation ECDataCache

+ (instancetype)sharedCache
{
    static ECDataCache *sharedCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCache = [[ECDataCache alloc] init];
    });

    return sharedCache;
}

#pragma mark - Helpers

+ (NSString *)cacheDirectory
{
    static NSString *cacheDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSArray *directories = [fileManager URLsForDirectory:NSCachesDirectory
                                                   inDomains:NSUserDomainMask];

        NSURL *cacheURL = [directories lastObject];

        NSURL *url = [cacheURL URLByAppendingPathComponent:@"ECDataCache"
                                               isDirectory:YES];

        cacheDirectory = [[url path] retain];

        if (![fileManager fileExistsAtPath:cacheDirectory]) {
            [fileManager createDirectoryAtPath:cacheDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
        }
    });

    return cacheDirectory;
}

+ (NSString *)keyForURL:(NSURL *)url
{
    return [url absoluteString];
}

+ (NSString *)pathForKey:(NSString *)key
{
    NSString *fileName = [key ec_MD5];
    return [[self cacheDirectory] stringByAppendingPathComponent:fileName];
}


#pragma mark - Getters

- (NSData *)dataForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }

    NSData *data = [super objectForKey:key];
    if (data) {
        return data;
    }

    return [self dataFromDiskForKey:key];
}

- (NSData *)dataForURL:(NSURL *)url
{
    return [self dataForKey:[[self class] keyForURL:url]];
}


#pragma mark - Setters

- (void)setData:(NSData *)data forKey:(NSString *)key
{
    if (!key || !data) {
        return;
    }

    // Set the NSCache store
    [super setObject:data forKey:key];

    // Set the disk cache
    [self setDataOnDisk:data forKey:key];
}

- (void)setData:(NSData *)data forURL:(NSURL *)url
{
    [self setData:data forKey:[[self class] keyForURL:url]];
}


#pragma mark - Deleters

- (void)removeDataForKey:(NSString *)key
{
    if (!key) {
        return;
    }

    // Remove the NSCache object
    [super removeObjectForKey:key];

    // Remove the disk cache
    [self removeDataOnDiskForKey:key];
}

- (void)removeDataForURL:(NSURL *)url
{
    [self removeDataForKey:[[self class] keyForURL:url]];
}


#pragma mark - Disk Interface

static dispatch_queue_t get_disk_cache_queue()
{
    static dispatch_queue_t diskCacheQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        diskCacheQueue = dispatch_queue_create("com.educreations.disk-cache.processing", NULL);
    });
    return diskCacheQueue;
}

static dispatch_queue_t get_disk_io_queue()
{
    static dispatch_queue_t diskIOQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        diskIOQueue = dispatch_queue_create("com.educreations.disk-cache.io", NULL);
    });
    return diskIOQueue;
}

- (NSData *)dataFromDiskForKey:(NSString *)key
{
    NSString *path = [[self class] pathForKey:key];

    __block NSData *response = nil;
    dispatch_sync(get_disk_cache_queue(), ^{
        response = [NSData dataWithContentsOfFile:path
                                          options:0
                                            error:nil];
    });

    return response;
}

- (void)setDataOnDisk:(NSData *)data forKey:(NSString *)key
{
    NSString *path = [[self class] pathForKey:key];

    dispatch_async(get_disk_io_queue(), ^{
        [data writeToFile:path
               atomically:YES];
    });
}

- (void)removeDataOnDiskForKey:(NSString *)key
{
    NSString *path = [[self class] pathForKey:key];

    dispatch_async(get_disk_io_queue(), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:nil];
    });
}

@end
