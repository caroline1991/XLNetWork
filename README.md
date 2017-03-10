# XLNetWork
动手实现一个自己的网络请求库。

一.基本的请求数据功能

1.XLRequestOperationProtocol协议包含一些请求相关操作的方法

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

2.请求实体基类XLRequestSuperObj遵守XLRequestOperationProtocol协议，并且包含一些@required或者@optional的属性

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

将自己的请求继承自XLRequestSuperObj调用XLRequestOperationProtocol协议中的请求方法，再配置一些基类XLRequestSuperObj的属性即可。


二.缓存功能的实现
引入XLNetWorkCacheManager.h文件 调用相应方法即可
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

后续会陆续增加上传，下载，多服务器切换，以及返回数据校验等功能。
