//
//  CSDNSParser.h
//  CSTools
//
//  Created by feng jia on 16/1/17.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDNSCache.h"

@protocol CSDNSParserDelegate <NSObject>

@required
- (NSDictionary *)defaultDnsInfo;

@end

typedef void(^CSDNSQueryCompletedBlock)(NSArray *ipList, CSDnsPolicy policy);

@interface CSDNSParser : NSObject

@property (readonly) BOOL bIgnoreDns;

+ (instancetype)instance;

- (void)fetchDnsInfo:(NSString *)host
                path:(NSString *)path
           parameter:(id)parameter
            delegate:(id<CSDNSParserDelegate>)delegate;

- (NSString *)currentIpForHost:(NSString *)host;




@end
