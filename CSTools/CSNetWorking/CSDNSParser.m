//
//  CSDNSParser.m
//  CSTools
//
//  Created by feng jia on 16/1/17.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import "CSDNSParser.h"
#import "CSNetClient.h"

@interface CSDNSParser ()

@property (nonatomic, strong) NSMutableDictionary *hostMapping;
@property (nonatomic, strong) NSMutableDictionary *ipsMapping;
@property (nonatomic, strong) NSMutableDictionary *policyMapping;
@property (nonatomic, copy) NSString *selectedIp;
@property CSDnsPolicy policy;


@property (nonatomic, assign) id<CSDNSParserDelegate> delegate;

@end

@implementation CSDNSParser

+ (void)load {
    
}

+ (instancetype)instance {
    static CSDNSParser *parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parser = [[CSDNSParser alloc] init];
    });
    return parser;
}

- (void)fetchDnsInfo:(NSString *)host path:(NSString *)path parameter:(id)parameter delegate:(id<CSDNSParserDelegate>)delegate {
    
    self.delegate = delegate;
    _bIgnoreDns = YES;
    
    CSNetRequestConfiguration *config = [[CSNetRequestConfiguration alloc] initWithHost:host];
    config.timeout = 30.0f;
    [[CSNetClient instance] cs_get:config parameter:parameter completeHandler:^(id responseData, NSError *error) {
        if (!error) {
            CSNetResponse *response = (CSNetResponse *)responseData;
            if (response.code == 10000 && [response.data isKindOfClass:[NSArray class]]) {
                [[CSDNSCache instance] saveDnsInfo:response.data];
            }
        }
        
    }];
}

- (NSString *)currentIpForHost:(NSString *)host {
    if (host) {
        return nil;
    }
    
    NSString *ip = self.hostMapping[host];
    if (!ip) {
        if (!self.ipsMapping[host]) {
            NSArray *ips = [[CSDNSCache instance] ipListCacheForHost:host];
            self.ipsMapping[host] = ips;
        }
        ip = [self retryNextIp:host];
        if (ip) {
            host = ip;
        }
    } else {
        host = ip;
    }
    return host;
}

- (NSString *)retryNextIp:(NSString *)host {
    NSMutableArray *ips = [NSMutableArray arrayWithArray:(NSArray *)self.ipsMapping[host]];
    if (ips.count > 0) {
        NSInteger index = 0;
        switch ([self cachePolicyByHost:host]) {
            case Random:
                index = arc4random()%ips.count;
                break;
            case Sequence:
                break;
            default:
                break;
        }
        host = ips[index];
        [ips removeObjectAtIndex:index];
        self.ipsMapping[host] = ips;
        
    }
    return host;
}

- (CSDnsPolicy)cachePolicyByHost:(NSString *)host {
    NSNumber *cachePolicy = self.policyMapping[host];
    if (!cachePolicy) {
        CSDnsPolicy policy = [[CSDNSCache instance] policyCacheForHost:host];
        cachePolicy = @(policy);
        self.policyMapping[host] = cachePolicy;
    }
    return [cachePolicy integerValue];
}

- (NSMutableDictionary *)ipsMapping {
    if (!_ipsMapping) {
        _ipsMapping = [NSMutableDictionary dictionary];
    }
    return _ipsMapping;
}

- (NSMutableDictionary *)hostMapping {
    if (!_hostMapping) {
        _hostMapping = [NSMutableDictionary dictionary];
    }
    return _hostMapping;
}

@end
