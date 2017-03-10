//
//  XLRequestTest.m
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/3/7.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import "XLRequestTest.h"

@implementation XLRequestTest

- (instancetype)init
{
    if (self = [super init]) {
        self.requestUrl = @"";
        self.needCache = YES;
    }
    return self;
}

- (XLRequestMethodType)requestMethod
{
    return XLRequestMethodTypeGet;
}

@end
