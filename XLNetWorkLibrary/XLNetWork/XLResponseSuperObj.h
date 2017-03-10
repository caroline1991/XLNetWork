//
//  XLResponseSuperObj.h
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/3/7.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLResponseSuperObj : NSObject <NSCopying>

/** 返回结果头 */
@property (nonatomic, strong) NSDictionary * responseHeader;
/** 返回结果data */
@property (nonatomic, strong) NSData * responsedata;
/** 返回结果json字符串 */
@property (nonatomic, strong) NSString * responseJsonString;
/** 返回结果HTTPURLResponse */
@property (nonatomic, strong) NSHTTPURLResponse * httpUrlRsponse;
/** 返回结果状态码 */
@property (nonatomic, assign) NSInteger statusCode;
/** 返回结果错误error */
@property (nonatomic, strong) NSError * error;

@end
