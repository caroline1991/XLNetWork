//
//  XLRequestObj.h
//  XLNetWorkLibrary
//
//  Created by 徐林 on 17/3/6.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLRequestOperationProtocol.h"

@interface XLRequestSuperObj : NSObject <XLRequestOperationProtocol>

/** 请求url */
@property (nonatomic, copy) NSString * requestUrl;
/** 是否取消请求 */
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
/** 是否正在执行请求 */
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;
/** 请求成功回调block */
@property (nonatomic, copy) XLRequestSuccessBlock successBlock;
/** 请求失败回调block */
@property (nonatomic, copy) XLRequestFailureBlock failureBlock;
/** 客户端判断是否需要缓存 YES && cacheInterval不赋时，缓存默认5分钟内有效 */
@property (nonatomic, assign) BOOL needCache;
/** 缓存时效，时间单位:秒 */
@property (nonatomic, assign) NSTimeInterval cacheInterval;

@end
