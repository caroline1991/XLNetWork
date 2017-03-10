//
//  XLResponseSuperObj.m
//  XLNetWorkLibrary
//
//  Created by xl10014 on 2017/3/7.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import "XLResponseSuperObj.h"

@implementation XLResponseSuperObj

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.responseHeader = [aDecoder decodeObjectForKey:@"responseHeader"];
        self.responsedata = [aDecoder decodeObjectForKey:@"responsedata"];
        self.responseJsonString = [aDecoder decodeObjectForKey:@"responseJsonString"];
        self.httpUrlRsponse = [aDecoder decodeObjectForKey:@"httpUrlRsponse"];
        self.statusCode = [[aDecoder decodeObjectForKey:@"statusCode"] integerValue];
        self.error = [aDecoder decodeObjectForKey:@"error"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.responseHeader forKey:@"responseHeader"];
    [aCoder encodeObject:self.responsedata forKey:@"responsedata"];
    [aCoder encodeObject:self.responseJsonString forKey:@"responseJsonString"];
    [aCoder encodeObject:self.httpUrlRsponse forKey:@"httpUrlRsponse"];
    [aCoder encodeObject:@(self.statusCode) forKey:@"statusCode"];
    [aCoder encodeObject:self.error forKey:@"error"];
}

@end
