//
//  CSNetClient.m
//  CSTools
//
//  Created by feng jia on 16/1/9.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import "CSNetClient.h"
#import "CSNetBaseModel.h"
#import <objc/runtime.h>
#import "CSNetHelper.h"

static char *kSSLSupport = "kHttpsSupport";
static char *kCertificatePaths = "kCertificatePaths";
static char *kUserAgent = "kUserAgent";
static char *kDomain = "kDomain";

@interface CSNetClient ()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableDictionary *requestMap;

@end

@implementation CSNetClient

+ (instancetype)instance {
    static CSNetClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[[self class] alloc] init];
    });
    return client;
}

- (instancetype)init {
    if (self = [super init]) {
        _sessionManager = [[AFHTTPSessionManager alloc] init];
    }
    return self;
}

+ (void)setDefaultSSLSurpport:(BOOL)surpport certificatePaths:(NSArray *)paths {
    objc_setAssociatedObject([self class], &kSSLSupport, @(surpport), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!paths) {
        paths = [NSArray array];
    }
    objc_setAssociatedObject([self class], &kCertificatePaths, paths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)defaultSSLSurpport {
    NSNumber *sslSurpport = objc_getAssociatedObject([self class], &kSSLSupport);
    return sslSurpport ? [sslSurpport boolValue] : NO;
}

+ (NSArray *)defaultCertificatePaths {
    return objc_getAssociatedObject([self class], &kCertificatePaths);
}

+ (void)setDefaultUserAgent:(NSString *)userAgent {
    if (userAgent) {
        objc_setAssociatedObject([self class], &kUserAgent, userAgent, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
+ (NSString *)defaultUserAgent {
    return objc_getAssociatedObject([self class], &kUserAgent);
}
+ (void)setDefaultDomain:(NSString *)domain {
    if (domain) {
        objc_setAssociatedObject([self class], &kDomain, domain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
+ (NSString *)defaultDomain {
    return objc_getAssociatedObject([self class], &kDomain);
}

#pragma mark - prepare

- (void)prepareForRequest:(CSNetRequest *)request {
    
    /**
     * 设置SSL支持
     * 全局设置后如果改变request中config中的ssl设置，则已后者为主
     */
    BOOL bSurpportHttps = [[self class] defaultSSLSurpport];
    if (bSurpportHttps && request.config.surpportSSL == SSL_DEFAULT) {
        request.config.surpportSSL = SSL_SURPPORT;
    }
    if (request.config.surpportSSL == SSL_SURPPORT) {
        NSArray *paths = nil;
        if (!request.config.certificatePath) {
            paths = [[self class] defaultCertificatePaths];
        }
        self.sessionManager.securityPolicy = [request customSecurityPolicy:paths];
    } else {
        self.sessionManager.securityPolicy = [request defaultSecurityPolicey];
    }
    
    //设置timeout
    self.sessionManager.requestSerializer.timeoutInterval = request.config.timeout;
    
    //设置header信息
    [self resetRequestHeader:request];
}

- (void)resetRequestHeader:(CSNetRequest *)request {
    
    /**
     *  先获取老的user-agent信息, 然后在后边拼接上我们设置的, 构成全新的user-agent
     */
    static dispatch_once_t onceToken;
    static NSString *oldUserAgent = @"";
    dispatch_once(&onceToken, ^{
        oldUserAgent = [self.sessionManager.requestSerializer.HTTPRequestHeaders objectForKey:@"User-Agent"];
    });
    
    //设置全局的UserAgent
    NSString *ua = [[self class] defaultUserAgent];
    if (ua) {
        ua = [NSString stringWithFormat:@"%@%@", oldUserAgent, ua];
        [self.sessionManager.requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
    }
    
    //设置全局Domain
    NSString *domain = [[self class] defaultDomain];
    if (domain) {
        [self.sessionManager.requestSerializer setValue:domain forHTTPHeaderField:@"Host"];
    }
    
    /**
     *  如果在request中 config中配置了header值，则使用config中新配置的
     */
    NSDictionary *headerMap = request.config.headerFieldMap;
    [headerMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (key && obj) {
            if ([key isEqualToString:@"User-Agent"]) {
                obj = [NSString stringWithFormat:@"%@%@", oldUserAgent, obj];
            }
            [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }
    }];
}
#pragma mark - send & cancel Request

- (void)cs_get:(CSNetRequestConfiguration *)config
     parameter:(id)parameter
completeHandler:(void(^)(id responseData, NSError *error))complete {
    [self cs_get:config parameter:parameter progress:nil completeHandler:complete];
}

- (void)cs_get:(CSNetRequestConfiguration *)config
     parameter:(id)parameter
      progress:(void(^)(NSProgress * _Nonnull downloadProgress))progress
completeHandler:(void(^)(id responseData, NSError *error))complete {
    CSNetRequest *request = [[CSNetRequest alloc] initWithConfig:config parameter:parameter method:Req_Get];
    request.progressBlock = progress;
    request.completeBlock = complete;
    [self sendRequest:request];
}

- (void)cs_post:(CSNetRequestConfiguration *)config
     parameter:(id)parameter
completeHandler:(void(^)(id responseData, NSError *error))complete {
    [self cs_post:config parameter:parameter progress:nil completeHandler:complete];
}

- (void)cs_post:(CSNetRequestConfiguration *)config
     parameter:(id)parameter
      progress:(void(^)(NSProgress * _Nonnull downloadProgress))progress
completeHandler:(void(^)(id responseData, NSError *error))complete {
    CSNetRequest *request = [[CSNetRequest alloc] initWithConfig:config parameter:parameter method:Req_Post];
    request.progressBlock = progress;
    request.completeBlock = complete;
    [self sendRequest:request];
}

- (void)sendRequest:(CSNetRequest *)request {
    
    [self prepareForRequest:request];
    
    NSString *url = request.config.url;
    NSLog(@"url: %@", url);
    NSLog(@"param: %@", request.parameter);
    switch (request.method) {
        case Req_Get: {
            @weakify(self);
            NSURLSessionTask *task = [self.sessionManager GET:url parameters:request.parameter progress:request.progressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                @strongify(self);
                [self handleSuccess:request responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                @strongify(self);
                [self handleFailed:request error:error];
            }];
            request.sessionTask = task;
            [self.requestMap setObject:request forKey:@([request.config.path hash])];
            
            break;
        }
        case Req_Post: {
            @weakify(self);
            NSURLSessionTask *task = [self.sessionManager POST:url parameters:request.parameter progress:request.progressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                @strongify(self);
                [self handleSuccess:request responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                @strongify(self);
                [self handleFailed:request error:error];
            }];
            request.sessionTask = task;
            [self.requestMap setObject:request forKey:@([request.config.path hash])];
            break;
        }
        default:
            break;
    }
}

- (void)handleSuccess:(CSNetRequest *)request responseObject:responseObject {
    NSLog(@"%@", request.config.url);
    NSLog(@"%@", responseObject);
    
    /**
     *  如果request配置了自动解析，则返回CSNetResponse对象，根据request中的配置进行对象解析
     *  否则，直接返回服务器的返回的jsonObject
     */
    if (request.config.bNeedAutoParser) {
        CSNetResponse *response = [[CSNetResponse alloc] initWithRequest:request result:responseObject];
        if (request.completeBlock) {
            request.completeBlock(response, nil);
        }
    } else {
        if (request.completeBlock) {
            request.completeBlock(responseObject, nil);
        }
    }
    
    [self.requestMap removeObjectForKey:@([request.config.path hash])];
}

- (void)handleFailed:(CSNetRequest *)request error:(NSError *)error {
    NSLog(@"%@", request.config.url);
    NSLog(@"%@", error);
    
    //手动cancel掉的请求不回调到上层
    if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"cancelled"]) {
        NSLog(@"Cancel the request [%@]", request.config.url);
        [self cancelRequest:request];
        return;
    }
    
    //根据request配置进行重试
    if (request.config.retryTime > request.retryCount) {
        [self retry:request];
    } else {
        if (request.completeBlock) {
            request.completeBlock(nil, error);
        }
        [self.requestMap removeObjectForKey:@([request.config.path hash])];
    }
}

- (void)cancelByRequestPath:(NSString *)requestPath {
    CSNetRequest *request = self.requestMap[@([requestPath hash])];
    
    if (request && request.sessionTask) {
        [request.sessionTask cancel];
        request.sessionTask = nil;
        [self.requestMap removeObjectForKey:@([requestPath hash])];
        
    }
}

- (void)cancelAllRequest {
    if (self.requestMap) {
        [[self.requestMap allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self cancelByRequestPath:obj];
        }];
        [self.requestMap removeAllObjects];        
    }
}

- (void)cancelRequest:(CSNetRequest *)request {
    [self cancelByRequestPath:request.config.path];
}

#pragma mark - Retry

- (void)retry:(CSNetRequest *)request {
    request.retryCount++;
    
    [self cancelRequest:request];
    [self sendRequest:request];
    
    NSLog(@"retry %ld times requesturl[%@]", (long)request.retryCount, request.config.url);
}

#pragma mark - Get & Set
- (NSMutableDictionary *)requestMap {
    if (!_requestMap) {
        _requestMap = [NSMutableDictionary dictionary];
    }
    return _requestMap;
}

@end

#pragma mark - Class CSNetRequest
#pragma mark -

@implementation CSNetRequest

- (instancetype)initWithConfig:(CSNetRequestConfiguration *)config
                     parameter:(id)param
                        method:(CSReqMethod)method {
    if (self = [super init]) {
        _config = config;
        _parameter = param;
        _method = method;
        self.retryCount = 0;
    }
    return self;
}

#pragma mark - Security

- (AFSecurityPolicy *)customSecurityPolicy:(NSArray *)cerPaths {
    
    //****SSL Pinnig *****
    /*
     *  如果config中配置了证书路径，则以config为准，否则使用default的paths
     */
    static AFSecurityPolicy *securityPolicy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *cerDataArray = [NSMutableArray array];
        if (self.config.certificatePath) {
            NSData *cerData = [NSData dataWithContentsOfFile:self.config.certificatePath];
            if (cerData) {
                [cerDataArray addObject:cerData];
            } else {
                NSLog(@"Can not get any data from the path: [%@]", self.config.certificatePath);
            }
        } else {
            if (cerPaths && [cerPaths isKindOfClass:[NSArray class]]) {
                [cerPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSData *cerData = [NSData dataWithContentsOfFile:obj];
                    if (cerData) {
                        [cerDataArray addObject:cerData];
                    } else {
                        NSLog(@"Can not get any data from the path: [%@]", obj);
                    }
                }];
            }
        }
        securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[NSSet setWithArray:cerDataArray]];
        [securityPolicy setAllowInvalidCertificates:NO];
    });
    
    return securityPolicy;
}

- (AFSecurityPolicy *)defaultSecurityPolicey {
    AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
    return security;
}

@end

#pragma mark - Class CSNetResponse
#pragma mark -

@implementation CSNetResponse

- (instancetype)initWithRequest:(CSNetRequest *)request result:(id)result {
    if (self = [super init]) {
        if (result && [result isKindOfClass:[NSDictionary class]]) {
            _code = [result[@"code"] integerValue];
            _message = result[@"message"];
            _attach = result[@"attached"];
            _data = result[@"data"];
            
            [self autoDataParser:request responseObject:result];
        }
    }
    return self;
}

#pragma mark - Data Parser
- (void)autoDataParser:(CSNetRequest *)request responseObject:(id)responseObject {
    if (!request) {
        return;
    }
    switch (request.config.returnType) {
        case ARRAY: {
            [self arrayParser:request];
            break;
        }
        case MODEL: {
            [self modelParser:request];
            break;
        }
        case DICTIONARY:
            break;
        case STRING: {
            self.data = [NSString stringWithFormat:@"%@", self.data];
            break;
        }
        case DATA:
            break;
        default:
            break;
    }
}

- (void)arrayParser:(CSNetRequest *)request {
    Class cla = request.config.modelCla;
    if ([self.data isKindOfClass:[NSArray class]] && cla) {
        NSMutableArray *array = [NSMutableArray array];
        if ([cla instancesRespondToSelector:@selector(initWithDictionary:)]) {
            [self.data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dict = (NSDictionary *)obj;
                    id model = [[cla alloc] initWithDictionary:dict];
                    if (!model) {
                        return ;
                    }
                    [array addObject:model];
                }
            }];
            self.data = array;
        } else {
            NSLog(@"error: Model need implement the method 'initWithDictionary', so return origin jsonObject directly");
        }
    } else {
        NSLog(@"error: The responseData is not the NSArray type or the model not exsit, so return origin jsonObject directly");
    }
}

- (void)modelParser:(CSNetRequest *)request {
    Class cla = request.config.modelCla;
    if (cla) {
        if ([cla instancesRespondToSelector:@selector(initWithDictionary:)]
            && [self.data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)self.data;
            id obj = [[cla alloc] initWithDictionary:dict];
            self.data = obj;
        } else {
            NSLog(@"error: Model need implement the init method 'initWithDictionary', so return origin jsonObject directly");
        }
    } else {
        NSLog(@"error: No config modelCla attr, return origin data directly, so return origin jsonObject directly");
    }
}


@end
