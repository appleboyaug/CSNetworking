//
//  CSDNSCache.h
//  CSTools
//
//  Created by feng jia on 16/1/17.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CSDnsPolicy) {
    Random,
    Sequence
};

@interface CSDNSCache : NSObject

+ (instancetype)instance;

- (void)saveDnsInfo:(id)dnsInfo;
- (NSArray *)ipListCacheForHost:(NSString *)host;
- (CSDnsPolicy)policyCacheForHost:(NSString *)host;

@end
