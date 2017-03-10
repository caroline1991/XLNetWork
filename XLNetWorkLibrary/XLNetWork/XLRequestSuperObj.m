//
//  XLRequestObj.m
//  XLNetWorkLibrary
//
//  Created by 徐林 on 17/3/6.
//  Copyright © 2017年 xl10014. All rights reserved.
//

#import "XLRequestSuperObj.h"
#import <objc/runtime.h>
#import "XLNetWorkCacheManager.h"

@interface XLRequestSuperObj()

@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURLSessionTask *requestTask;
@property (nonatomic, strong) NSMutableURLRequest * request;
@property (nonatomic, assign) XLRequestMethodType type;
@property (nonatomic, strong) XLResponseSuperObj * responseSupObj;

@end

@implementation XLRequestSuperObj

#pragma mark - XLRequestObjectProtocol
-(void)startWithCompletionBlockWithSuccess:(XLRequestSuccessBlock)success failure:(XLRequestFailureBlock)failure
{
    self.session = [NSURLSession sharedSession];
    self.responseSupObj = [[XLResponseSuperObj alloc] init];
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)clearCompletionBlock
{ 
    self.successBlock = nil;
    self.failureBlock = nil;
}

- (XLRequestMethodType)requestMethod
{
    return XLRequestMethodTypeGet;
}

- (void)start
{
    [self configRequestHeader];
    [self configRequestRow];
    [self configRequestBody];
    if ([[XLNetWorkCacheManager defaultManager] objcetForKey:self.requestUrl]) {
        self.responseSupObj = [[XLNetWorkCacheManager defaultManager] objcetForKey:self.requestUrl];
        if (self.successBlock) {
            self.successBlock(self.responseSupObj.responseJsonString,self.responseSupObj);
        }
        [self clearCompletionBlock];
        return;
    }

    self.requestTask = [self.session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self handleRequestAfterMessage:data httpUrlResponse:response error:error];
    }];
    [self.requestTask resume];
}

- (void)cancel
{
    NSAssert(self.requestTask != nil, @"requestTask should not be nil");
    
    [self.requestTask cancel];
    [self clearCompletionBlock];
}

#pragma mark - config requestInfo
- (void)configRequestRow
{
    NSString * requestMethod = @"";
    switch ([self requestMethod]) {
        case XLRequestMethodTypeGet:
        {
            requestMethod = @"GET";
            self.type = XLRequestMethodTypeGet;
        }
            break;
        case XLRequestMethodTypePost:
        {
            requestMethod = @"POST";
            self.type = XLRequestMethodTypePost;
        }
            break;
        case XLRequestMethodTypePUT:
        {
            requestMethod = @"PUT";
            self.type = XLRequestMethodTypePUT;
        }
            break;
        case XLRequestMethodTypeDELETE:
        {
            requestMethod = @"DELETE";
            self.type = XLRequestMethodTypeDELETE;
        }
            break;
        case XLRequestMethodTypePATCH:
        {
            requestMethod = @"PATCH";
            self.type = XLRequestMethodTypePATCH;
        }
            break;
        case XLRequestMethodTypeHEAD:
        {
           requestMethod = @"HEAD";
            self.type = XLRequestMethodTypeHEAD;
        }
            break;
        default:
            break;
    }
    self.request.HTTPMethod = requestMethod;
}

- (void)configRequestHeader
{
    NSURL * url = [NSURL URLWithString:[self getAbsoluteUrlString]];
    self.request = [[NSMutableURLRequest alloc] initWithURL:url];
}

- (void)configRequestBody
{
    NSMutableData * data = [[NSMutableData alloc] init];
    unsigned int ivarCount = 0;
    class_copyIvarList(self.class, &ivarCount);
    if (self.type == XLRequestMethodTypePost && ivarCount > 0) {
        [data appendData:[[self getAbsoluteUrlString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    self.request.HTTPBody =  data;
}

#pragma mark - Funtion

- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

- (void)handleRequestAfterMessage:(NSData *)data httpUrlResponse:(NSURLResponse *)httpUrlResponse error:(NSError *)error
{
    self.responseSupObj.httpUrlRsponse = (NSHTTPURLResponse *)httpUrlResponse;
    self.responseSupObj.responseJsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.responseSupObj.responsedata = data;
    self.responseSupObj.error = error;
    self.responseSupObj.responseHeader = self.responseSupObj.httpUrlRsponse.allHeaderFields;
    self.responseSupObj.statusCode = self.responseSupObj.httpUrlRsponse.statusCode;
    
    if (error) {
        if (self.failureBlock) {
            self.failureBlock(error,self.responseSupObj);
        }
    } else {
        if (self.successBlock) {
            self.successBlock(self.responseSupObj.responseJsonString,self.responseSupObj);
        }
    }
    [self clearCompletionBlock];
    
    if (self.needCache == YES) {
        [[XLNetWorkCacheManager defaultManager] setObject:self.responseSupObj forKey:self.requestUrl cacheTimeInterval:self.cacheInterval > 0?self.cacheInterval:0];
    }
}

- (NSString *)getAbsoluteUrlString
{
    NSAssert(self.requestUrl != nil, @"requestUrl should not be nil");
    
    NSString * absoluteUrlString = self.requestUrl;
    unsigned int ivarCount = 0;
    class_copyIvarList(self.class, &ivarCount);
    if (ivarCount > 0 && self.type == XLRequestMethodTypeGet) {
        absoluteUrlString = [NSString stringWithFormat:@"%@?%@",absoluteUrlString,[self getRequestUrlParamsString]];
    }
    return absoluteUrlString;
}

- (NSString *)getRequestUrlParamsString{
    NSMutableDictionary * paramDict = [[NSMutableDictionary alloc] init];
    unsigned int ivarCount = 0;
    Ivar * ivars = class_copyIvarList(self.class, &ivarCount);
    for (int i = 0; i < ivarCount; i++) {
        Ivar ivar = ivars[i];
        NSMutableString * name = [NSMutableString string];
        if (ivar_getName(ivar)) {
            [name appendString:[NSString stringWithUTF8String:ivar_getName(ivar)]];
            [name deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        id value = object_getIvar(self, ivar);
        [paramDict setObject:value?value:@"" forKey:name];
    }
    NSMutableString *paramString = [NSMutableString string];
    [paramDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramString appendFormat:@"%@=%@&", key, obj];
    }];
    return [paramString substringToIndex:(paramString.length-1)];
}

@end
