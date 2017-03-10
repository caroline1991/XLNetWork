//
//  XLNetWorkCacheManager.m
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/3/9.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import "XLNetWorkCacheManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static double const kMemoryCacheTimeInterval = 60*5; //内存默认缓存有效期
static double const kDiskCacheTimeInterval = 60*60*24;//硬盘默认缓存有效期
static NSString * kStorageName = @"XLCacheStorage"; //硬盘缓存路径添加结点

@interface XLNetWorkStorageMemory ()

@property (nonatomic, strong) id data;
@property (nonatomic, assign) NSTimeInterval cacheTime;
@property (nonatomic, assign) NSTimeInterval validTimeInterval;

@end


@implementation XLNetWorkStorageMemory

#pragma mark - default funtion

+ (XLNetWorkStorageMemory *)storageMemoryWithData:(id)data cacheTimeInterval:(NSTimeInterval)timeInterval
{
    XLNetWorkStorageMemory * object = [[XLNetWorkStorageMemory alloc] init];
    object.data          = data;
    object.cacheTime = [[NSDate date] timeIntervalSince1970];
    object.validTimeInterval = timeInterval > 0 ? timeInterval : kMemoryCacheTimeInterval;
    return object;
}

- (BOOL)isValid
{
    if (self.data && [[NSDate date] timeIntervalSince1970] - self.cacheTime < self.validTimeInterval) {
        return YES;
    }
    return NO;
}

@end


@interface XLNetWorkStorageDisk()

@property (nonatomic, strong) id data;
@property (nonatomic, assign) NSTimeInterval cacheTime;
@property (nonatomic, assign) NSTimeInterval validTimeInterval;

@end

@implementation XLNetWorkStorageDisk

#pragma mark - NSCopying

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.cacheTime =  [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(cacheTime))] doubleValue];
        self.validTimeInterval = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(validTimeInterval))] doubleValue];
        self.data = [aDecoder decodeObjectOfClass:[NSData class] forKey:NSStringFromSelector(@selector(data))];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.data forKey:NSStringFromSelector(@selector(data))];
    [aCoder encodeObject:@(self.cacheTime) forKey:NSStringFromSelector(@selector(cacheTime))];
    [aCoder encodeObject:@(self.validTimeInterval) forKey:NSStringFromSelector(@selector(validTimeInterval))];
}

#pragma mark - default funtion

+ (XLNetWorkStorageDisk *)storageDiskWithData:(id)data key:(NSString *)key cacheTimeInterval:(NSTimeInterval)timeInterval
{
    XLNetWorkStorageDisk * object = [[XLNetWorkStorageDisk alloc] init];
    object.data = data;
    object.cacheTime = [[NSDate date] timeIntervalSince1970];
    object.validTimeInterval = timeInterval > 0 ? timeInterval : kDiskCacheTimeInterval;
    return object;
}

- (BOOL)isValid
{
    if (self.data && [[NSDate date] timeIntervalSince1970] - self.cacheTime < self.validTimeInterval) {
        return YES;
    }
    return NO;
}

@end


@interface XLNetWorkCacheManager()

@property (nonatomic, strong) NSCache * cache;

@end

@implementation XLNetWorkCacheManager

#pragma mark - default funtion

+ (instancetype)defaultManager
{
    static XLNetWorkCacheManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
        [instance configuration];
    });
    return instance;
}

- (void)configuration
{
    self.cache = [[NSCache alloc] init];
    self.cache.totalCostLimit = 1024 * 1024 * 20;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWaring) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)setObject:(id)object forKey:(id)key
{
    if (!key) {
        return;
    }
    [self setObject:object forKey:key cacheTimeInterval:0];
}

- (void)setObject:(id)object forKey:(id)key cacheTimeInterval:(NSTimeInterval)timeInterval
{
    if (!key) {
        return;
    }
    [self removeObjectForKey:key];
    [self cacheMemoryObject:object key:key cacheTimeInterval:timeInterval];
    [self cacheDiskObject:object key:key cacheTimeInterval:timeInterval];
}

- (void)removeObjectForKey:(id)key
{
    if (!key) {
        return;
    }
    [self.cache removeObjectForKey:key];
    NSString * path = [self filePathWithKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

-(void)removeAllObject
{
    [self.cache removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:[self filePathWithKey:nil] error:nil];
}

- (id)objcetForKey:(id)key
{
    if (!key) {
        return nil;
    }
    XLNetWorkStorageMemory * memoryCacheObj = [self.cache objectForKey:key];
    if ([memoryCacheObj isValid]) return memoryCacheObj.data;
    XLNetWorkStorageDisk * diskCacheObj = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathWithKey:key]];
    if ([diskCacheObj isValid]) return diskCacheObj.data;
    return nil;
}

#pragma mark - other funtion

- (void)cacheMemoryObject:(id)object key:(id)key cacheTimeInterval:(NSTimeInterval)timeInterval
{
    XLNetWorkStorageMemory * memoryObj =  [XLNetWorkStorageMemory storageMemoryWithData:object cacheTimeInterval:timeInterval > 0 ? timeInterval : kMemoryCacheTimeInterval];
    [self.cache setObject:memoryObj forKey:key];
}

- (void)cacheDiskObject:(id)object key:(id)key cacheTimeInterval:(NSTimeInterval)timeInterval
{
    XLNetWorkStorageDisk * diskObj = [XLNetWorkStorageDisk storageDiskWithData:object key:key cacheTimeInterval:timeInterval > 0 ? timeInterval : kDiskCacheTimeInterval];
    NSString * path = [self filePathWithKey:key];
    if (path.length && ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        [NSKeyedArchiver archiveRootObject:diskObj toFile:path];
    }
}

- (void)handleMemoryWaring
{
    [self removeAllObject];
}

/** 硬盘存储路径 */
- (NSString *)filePathWithKey:(id)key
{
    NSString * cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) firstObject];
    NSString * pathStorageName = [cacheFolder stringByAppendingPathComponent:kStorageName];
    if (key) {
        return [pathStorageName stringByAppendingPathComponent:key];
    }
    return pathStorageName;
}

@end
