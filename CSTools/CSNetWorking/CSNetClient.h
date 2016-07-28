//
//  CSNetClient.h
//  CSTools
//
//  Created by feng jia on 16/1/9.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "CSNetRequestConfiguration.h"

#pragma mark - Class CSNetClient

typedef NS_ENUM(NSInteger, CSReqMethod) {
    Req_Get,
    Req_Post
};

/**
 *  依赖AFNetworking来实现网络请求
 */
@interface CSNetClient : NSObject

+ (instancetype)instance;

#pragma mark - Request
/**
 *  get request
 *
 *  @param config    request config
 *  @param parameter parameter
 *  @param complete  complete block
 */
- (void)cs_get:(CSNetRequestConfiguration *)config
     parameter:(id)parameter
completeHandler:(void(^)(id responseData, NSError *error))complete;

/**
 *  get request with progress
 *
 *  @param config    request config
 *  @param parameter parameter
 *  @param progress  progress block
 *  @param complete  complete block
 */
- (void)cs_get:(CSNetRequestConfiguration *)config
     parameter:(id)parameter
      progress:(void(^)(NSProgress * downloadProgress))progress
completeHandler:(void(^)(id responseData, NSError *error))complete;

/**
 *  post request
 *
 *  @param config    request config
 *  @param parameter parameter
 *  @param complete  complete block
 */
- (void)cs_post:(CSNetRequestConfiguration *)config
      parameter:(id)parameter
completeHandler:(void(^)(id responseData, NSError *error))complete;

/**
 *  post request with progress
 *
 *  @param config    request config
 *  @param parameter parameter
 *  @param progress  progress block
 *  @param complete  complete block
 */
- (void)cs_post:(CSNetRequestConfiguration *)config
     parameter:(id)parameter
      progress:(void(^)(NSProgress * downloadProgress))progress
completeHandler:(void(^)(id responseData, NSError *error))complete;

/**
 *  cancel a request by path
 *
 *  @param requestPath request path
 */
- (void)cancelByRequestPath:(NSString *)requestPath;

/**
 *  cancel all requests
 */
- (void)cancelAllRequest;

#pragma mark - Globle Default Value

/**
 *  全局设置 SSL Surpport 功能，需要传入公钥path （可放在工程资源文件下），设置后默认所有request都支持Https请求
 *  如果针对某个request的config中的SSL功能进行了配置，则优先生效
 *
 *  @param surpport 是否支持SSL
 *  @param paths    公钥路径
 */
+ (void)setDefaultSSLSurpport:(BOOL)surpport certificatePaths:(NSString *)paths;
+ (BOOL)defaultSSLSurpport;
+ (NSArray *)defaultCertificatePaths;

/**
 *  在request header中设置全局的UserAgent和Domain字段
 *  如果reqeust的config中配置headerfield值，则优先生效
 */
+ (void)setDefaultUserAgent:(NSString *)userAgent;
+ (NSString *)defaultUserAgent;
+ (void)setDefaultDomain:(NSString *)domain;
+ (NSString *)defaultDomain;

@end

#pragma mark -
#pragma mark - Class CSNetRequest

/**
 *  请求的request封装
 */

@interface CSNetRequest : NSObject {
    CSNetRequestConfiguration *_config;
    id _parameter;
    CSReqMethod _method;
}
@property (nonatomic, strong) NSURLSessionTask *sessionTask;

//request的配置信息
@property (nonatomic, strong, readonly) CSNetRequestConfiguration *config;

//request 参数
@property (nonatomic, strong, readonly) id parameter;

//request 方式 get/post
@property (readonly) CSReqMethod method;

//retry 次数
@property NSInteger retryCount;

@property (nonatomic, copy) void(^progressBlock)(NSProgress * downloadProgress);
@property (nonatomic, copy) void(^completeBlock)(id responseData, NSError *error);

/**
 *  init
 *
 *  @param config request config
 *  @param param  parameter
 *  @param method get/post
 *
 *  @return self
 */
- (instancetype)initWithConfig:(CSNetRequestConfiguration *)config
                     parameter:(id)param
                        method:(CSReqMethod)method;
/**
 *  自定义security
 *
 *  @return AFSecurityPolicy Obj
 */
- (AFSecurityPolicy *)customSecurityPolicy:(NSArray *)cerPaths;
/**
 *  default security
 *
 *  @return AFSecurityPolicy Obj
 */
- (AFSecurityPolicy *)defaultSecurityPolicey;

@end

#pragma mark -
#pragma mark - Class CSNetResponse

/**
 *  返回Response封装
 */

@interface CSNetResponse : NSObject

@property NSInteger statusCode;
@property (nonatomic, strong) NSError *error;


/**
 *  api返回的业务数据
 */
@property (readonly) NSInteger code;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) id attach;

/**
 *  init
 *
 *  @param request request
 *  @param result  responseObjct
 *
 *  @return self
 */
- (instancetype)initWithRequest:(CSNetRequest *)request result:(id)result;

@end
