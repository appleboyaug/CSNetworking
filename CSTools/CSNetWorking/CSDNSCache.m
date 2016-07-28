//
//  CSDNSCache.m
//  CSTools
//
//  Created by feng jia on 16/1/17.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import "CSDNSCache.h"

@interface CSDNSCache ()

@property (nonatomic, strong) NSMutableDictionary *dnsCache;

@end

@implementation CSDNSCache

+ (instancetype)instance {
    static CSDNSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[CSDNSCache alloc] init];
    });
    return cache;
}

- (void)saveDnsInfo:(id)dnsInfo {
    if (dnsInfo) {
        [NSKeyedArchiver archiveRootObject:dnsInfo toFile:[self pathForDnsInfo]];
    }
}

- (NSArray *)ipListCacheForHost:(NSString *)host {
    NSDictionary *dnsInfoCache = [self dnsInfoFromCache:host];
    if (dnsInfoCache) {
        return dnsInfoCache[@"ipList"];
    }
    return [NSArray array];
}
- (CSDnsPolicy)policyCacheForHost:(NSString *)host {
    NSDictionary *dnsInfoCache = [self dnsInfoFromCache:host];
    if (dnsInfoCache) {
        return [dnsInfoCache[@"policy"] integerValue];
    }
    return Random;
}

- (NSDictionary *)dnsInfoFromCache:(NSString *)host {
    __block NSDictionary *dnsInfoCache = nil;
    if (self.dnsCache && host) {
        if (self.dnsCache[host]) {
            dnsInfoCache = self.dnsCache;
            return dnsInfoCache;
        }
    }
    NSString *path = [self pathForDnsInfo];
    NSArray *dnsInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (dnsInfo && [dnsInfo isKindOfClass:[NSArray class]]) {
        [dnsInfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSString *domain = obj[@"domain"];
                if ([host isEqualToString:domain]) {
                    self.dnsCache[host] = obj;
                    dnsInfoCache = obj;
                    *stop = YES;
                }
            }
        }];
    }
    return dnsInfoCache;
}

- (NSString *)pathForDnsInfo {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:@"dns.archive"];
    return path;
}

@end
