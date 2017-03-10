//
//  XLNetWorkCacheManager.h
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/3/9.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLNetWorkStorageMemory : NSObject

/** 获取内存缓存存储对象 */
+ (XLNetWorkStorageMemory *)storageMemoryWithData:(id)data cacheTimeInterval:(NSTimeInterval)timeInterval;
/** 判断对象是否超过缓存有效期 */
- (BOOL)isValid;

@end


@interface XLNetWorkStorageDisk : NSObject <NSCopying>

/** 获取硬盘缓存存储对象 */
+ (XLNetWorkStorageDisk *)storageDiskWithData:(id)data key:(NSString *)key cacheTimeInterval:(NSTimeInterval)timeInterval;
/** 判断对象是否超过缓存有效期 */
- (BOOL)isValid;

@end


@interface XLNetWorkCacheManager : NSObject

+ (instancetype)defaultManager;

/** 存储object 不传缓存时间默认 内存下5分钟 硬盘下24小时 */
- (void)setObject:(id)object forKey:(id)key;

/** 存储object ＋ 缓存时间 */
- (void)setObject:(id)object forKey:(id)key cacheTimeInterval:(NSTimeInterval)timeInterval;

/** 移除某个key对应object */
- (void)removeObjectForKey:(id)key;

/** 移除所有缓存object */
- (void)removeAllObject;

/** 根据key获取对应object */
- (id)objcetForKey:(id)key;


@end
