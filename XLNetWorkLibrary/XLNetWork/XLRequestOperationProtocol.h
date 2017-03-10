//
//  XLRequestObjectProtocol.h
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/3/7.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLResponseSuperObj.h"

/** 请求方法枚举 */
typedef NS_ENUM(NSInteger, XLRequestMethodType) {
    XLRequestMethodTypeGet,
    XLRequestMethodTypePost,
    XLRequestMethodTypeHEAD,
    XLRequestMethodTypePUT,
    XLRequestMethodTypeDELETE,
    XLRequestMethodTypePATCH
};

/** 请求成功回调block */
typedef void(^XLRequestSuccessBlock)(NSString * responseJsonString, XLResponseSuperObj * responseSupObj) ;
/** 请求失败回调block */
typedef void(^XLRequestFailureBlock)(NSError *error, XLResponseSuperObj * responseSupObj) ;

@protocol XLRequestOperationProtocol <NSObject>

/** 请求方法 */
- (XLRequestMethodType)requestMethod;
/** 发起请求 */
- (void)startWithCompletionBlockWithSuccess:(XLRequestSuccessBlock)success
                                    failure:(XLRequestFailureBlock)failure;
/** 开始请求 */
- (void)start;
/** 取消请求 */
- (void)cancel;
/** 移除回调block */
- (void)clearCompletionBlock;

@end
