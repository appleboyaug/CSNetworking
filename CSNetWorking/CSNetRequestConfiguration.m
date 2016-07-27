//
//  CSNetRequestConfiguration.m
//  CSTools
//
//  Created by feng jia on 16/1/9.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import "CSNetRequestConfiguration.h"
#import "CSDNSParser.h"

#define TIMEOUTINTERVAL       10

@implementation CSNetRequestConfiguration

- (instancetype)initWithHost:(NSString *)host {
    if (self = [super init]) {
        self.host = host;
        self.path = @"";
        self.retryTime = 3;  //default retry 3 times
        self.bNeedAutoParser = YES;
        self.returnType = DEFAULT;
        self.surpportSSL = SSL_DEFAULT;
        self.timeout = TIMEOUTINTERVAL;
    }
    return self;
}

- (instancetype)init {
    return [self initWithHost:@""];
}

- (NSString *)url {
    if (cs_strNull(self.host)) {
        return @"";
    }
    
    NSMutableString *httpUrl = [[NSMutableString alloc] initWithString:@""];
    if (self.surpportSSL == SSL_SURPPORT) {
        if (![self.host hasPrefix:@"https://"] && ![self.host hasPrefix:@"http://"]) {
            [httpUrl appendString:@"https://"];
        }
    } else {
        if (![self.host hasPrefix:@"http://"] && ![self.host hasPrefix:@"https://"]) {
            [httpUrl appendString:@"http://"];
        }
    }
    
    [httpUrl appendString:self.host];
    
    if (![self.host hasSuffix:@"/"]) {
        [httpUrl appendString:@"/"];
    }
    
    if (cs_strNull(self.path)) {
        return self.host;
    }
    
    if ([self.path hasPrefix:@"/"]) {
        self.path = [self.path substringFromIndex:1];
    }
    
    [httpUrl appendString:self.path];
    
    if ([httpUrl hasSuffix:@"?"]) {
        [httpUrl replaceCharactersInRange:NSMakeRange(httpUrl.length-1, 1) withString:@""];
    }

    return httpUrl;
}

- (NSString *)dnsUrl {
    NSString *url = self.host;
    if ([self checkIgnoreDns]) {
        NSString *ip = [[CSDNSParser instance] currentIpForHost:self.host];
        if (ip) {
            url = ip;
        }
    }
    
    return url;
}

- (BOOL)checkIgnoreDns {
    BOOL bIgnoreDns = NO;
    if (self.dnsStatus == DNS_NORMAL || self.dnsStatus == DNS_IGNORE) {
        if (self.dnsStatus == DNS_IGNORE) {
            bIgnoreDns = YES;
        }
    } else {
        if ([CSDNSParser instance].bIgnoreDns) {
            bIgnoreDns = YES;
        }
        
    }
    return bIgnoreDns;
}

@end
