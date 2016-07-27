//
//  CSNetHelper.m
//  CSTools
//
//  Created by feng jia on 16/1/12.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import "CSNetHelper.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworkReachabilityManager.h"


@implementation CSNetHelper

+ (NSString *)cs_urlParametersStringFromParameters:(NSDictionary *)parameters {
    NSMutableString *urlParametersString = [[NSMutableString alloc] initWithString:@""];
    if (parameters && parameters.count > 0) {
        for (NSString *key in parameters) {
            NSString *value = parameters[key];
            value = [NSString stringWithFormat:@"%@",value];
            value = [self cs_urlEncode:value];
            [urlParametersString appendFormat:@"&%@=%@", key, value];
        }
    }
    return urlParametersString;
}

+ (NSString *)cs_urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters {
    NSString *filteredUrl = originUrlString;
    NSString *paraUrlString = [self cs_urlParametersStringFromParameters:parameters];
    if (paraUrlString && paraUrlString.length > 0) {
        if ([originUrlString rangeOfString:@"?"].location != NSNotFound) {
            filteredUrl = [filteredUrl stringByAppendingString:paraUrlString];
        } else {
            filteredUrl = [filteredUrl stringByAppendingFormat:@"?%@", [paraUrlString substringFromIndex:1]];
        }
        return filteredUrl;
    } else {
        return originUrlString;
    }
}

+ (NSString*)cs_urlEncode:(NSString*)str {
    //different library use slightly different escaped and unescaped set.
    //below is copied from AFNetworking but still escaped [] as AF leave them for Rails array parameter which we don't use.
    //https://github.com/AFNetworking/AFNetworking/pull/555
    NSString *result = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f) {
        result = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"\":/?#[]@!$&'()*+,;=\""]];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, CFSTR("."), CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
#pragma clang diagnostic pop
    }
    return result;
}

+ (NSString *)cs_md5StringFromString:(NSString *)string {
    if(string == nil || [string length] == 0)
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}


+ (NSDictionary *)cs_deviceInfo {
    return  @{@"simType": [self cs_simType],
              @"netType": [self cs_netType],
              @"deviceTypeId": @"02",
              @"detailInfo": [self cs_phoneType],
              @"osVersion": [self cs_osVersion],
              @"osTypeId": @"02",
              @"idfa": [self cs_idfa] ? [self cs_idfa] : @"",
              @"deviceId": [self cs_deviceId]};
}

//设备deviceid
+ (NSString *)cs_deviceId {
    NSString *idfa = [self cs_idfa];
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    if (idfa) {
        return [self cs_md5StringFromString:[NSString stringWithFormat:@"%@%@", idfa, bundleId]];
    } else {
        return @"";
    }
}

+ (NSString *)cs_idfa {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
#else
    return nil;
#endif
}

+ (NSString *)cs_idfv {
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC)
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f)  {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
    
    return nil;
}
//运营商
+ (NSString *)cs_simType {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    if ([mcc intValue] == 460) {
        
    }
    NSString *mnc = [carrier mobileNetworkCode];
    if (mnc == nil) {
        return @"00";
    }
    
    if ([mnc isEqualToString:@"00"] || [mnc isEqualToString:@"02"] || [mnc isEqualToString:@"07"]) {
        return  @"01"; // @"移动"
    } else if ([mnc isEqualToString:@"01"] || [mnc isEqualToString:@"06"])
    {
        return @"02";// @"联通"
    } else if ([mnc isEqualToString:@"03"] || [mnc isEqualToString:@"05"] || [mnc isEqualToString:@"20"])
    {
        return @"03"; // @"电信"
    } else{
        return @"00";
    }
}
//联网方式
+ (NSString *)cs_netType {
    NSString *network = nil;
    AFNetworkReachabilityStatus status = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    if (status == AFNetworkReachabilityStatusNotReachable) {
        network = @"00";
    } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        network = @"02";
    } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        network = @"01"; //"@"wifi"
    }
    return network ? network : @"00";
}
//手机型号
+ (NSString *)cs_phoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    return code;
}
//App版本
+ (NSString *)cs_appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
//系统版本
+ (NSString *)cs_osVersion {
    return [UIDevice currentDevice].systemVersion;
}

//app name
+ (NSString *)cs_appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
}

//channel
+ (NSString *)cs_channel {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"channel" ofType:@"txt"];
    NSString *c = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return [c stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)cs_userAgent:(NSString *)credential appName:(NSString *)appName {
    // @" Wuli/"
    NSMutableString *useragent = [[NSMutableString alloc] initWithString:appName?:@""];
    [useragent appendString:[self cs_appVersion]];
    [useragent appendString:@" (agent:S;"];
    [useragent appendFormat:@"channel:%@;", [self cs_channel]];
    [useragent appendFormat:@"credential:%@;", credential?:@"null"];
    [useragent appendFormat:@"deviceId:%@;", [self cs_deviceId]];
    [useragent appendString:@"osTypeId:02;"];
    [useragent appendFormat:@"detailInfo:%@;", [self cs_phoneType]];
    [useragent appendFormat:@"simTypeId:%@;", [self cs_simType]];
    [useragent appendFormat:@"netTypeId:%@;", [self cs_netType]];
    [useragent appendString:@"deviceTypeId:02;"];
    [useragent appendFormat:@"osVersion:%@;", [self cs_osVersion]];
    [useragent appendFormat:@"idfa:%@)", [self cs_idfa]];
    return useragent;
}

@end
