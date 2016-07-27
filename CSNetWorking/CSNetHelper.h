//
//  CSNetHelper.h
//  CSTools
//
//  Created by feng jia on 16/1/12.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSNetHelper : NSObject

+ (NSString *)cs_urlParametersStringFromParameters:(NSDictionary *)parameters;
+ (NSString *)cs_urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters;
+ (NSString *)cs_md5StringFromString:(NSString *)string;

//-----------------------------------------------------------------
+ (NSDictionary *)cs_deviceInfo;
//设备deviceid
+ (NSString *)cs_deviceId;
//运营商
+ (NSString *)cs_simType;
//联网方式
+ (NSString *)cs_netType;
//手机型号
+ (NSString *)cs_phoneType;
//App版本
+ (NSString *)cs_appVersion;
//系统版本
+ (NSString *)cs_osVersion;
//idfa
+ (NSString *)cs_idfa;
//idfv
+ (NSString *)cs_idfv;
//channel
+ (NSString *)cs_channel;
//appName
+ (NSString *)cs_appName;
//useragent
+ (NSString *)cs_userAgent:(NSString *)credential appName:(NSString *)appName;
//-----------------------------------------------------------------
@end
