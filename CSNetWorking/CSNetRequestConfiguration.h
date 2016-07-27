//
//  CSNetRequestConfiguration.h
//  CSTools
//
//  Created by feng jia on 16/1/9.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSAppDefine.h"

typedef NS_ENUM(NSInteger, CSNetReturnType) {
    DEFAULT,
    DICTIONARY,
    ARRAY,
    MODEL,
    STRING,
    DATA
};

typedef NS_ENUM(NSInteger, CSSSLSurpport) {
    SSL_DEFAULT,
    SSL_SURPPORT,
    SSL_NOTSURPPORT
};

typedef NS_ENUM(NSInteger, CSDnsStatus) {
    DNS_DEFAULT,
    DNS_IGNORE,
    DNS_NORMAL
};

@interface CSNetRequestConfiguration : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *headerDomain;  //域名
@property (nonatomic, copy) NSString *host;    //域名或者ip
@property (nonatomic, copy) NSString *path;    //访问path
@property NSInteger retryTime;          //重试次数
@property int timeout;                  //超时时间
@property CSSSLSurpport surpportSSL;    //是否支持https
@property (nonatomic, copy) NSString *certificatePath;  //SSL证书路径
@property (nonatomic, strong) NSDictionary *headerFieldMap;  //自定义header中的内容

@property CSDnsStatus dnsStatus;     //是否需要进行dns解析

/***** 自动解析相关 *****/
@property BOOL bNeedAutoParser;         //是否进行自动解析
@property (nonatomic, strong) Class modelCla;  //解析的model类型
@property CSNetReturnType returnType;   //解析的返回类型

- (instancetype)initWithHost:(NSString *)host;

@end
