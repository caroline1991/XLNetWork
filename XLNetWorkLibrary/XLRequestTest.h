//
//  XLRequestTest.h
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/3/7.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import "XLRequestSuperObj.h"

/** 网络请求例子 请求体继承自XLRequestSuperObj
    请求参数写在请求实体类中，父类中会利用runtime去拿到并且拼接为url请求参数
 */

@interface XLRequestTest : XLRequestSuperObj

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * age;

@end
