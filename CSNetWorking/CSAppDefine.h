//
//  CSAppDefine.h
//  CSTools
//
//  Created by feng jia on 16/1/9.
//  Copyright © 2016年 caishi. All rights reserved.
//

#ifndef CSAppDefine_h
#define CSAppDefine_h

#pragma mark -
#pragma mark Macro

#define cs_AppVer [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define cs_SystemVer ([[UIDevice currentDevice] systemVersion])
#define cs_DeviceName [UIDevice currentDevice].model

#define cs_iOS9   ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0f) ? YES : NO
#define cs_iOS8   ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) ? YES : NO
#define cs_iOS7   ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) ? YES : NO

#define cs_ScreenW ([[UIScreen mainScreen] bounds].size.width)
#define cs_ScreenH ([[UIScreen mainScreen] bounds].size.height)
#define cs_IsIphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define cs_iPhone_4_or_less (cs_isIphone && cs_ScreenH < 568.0)
#define cs_iPhone_5_or_more (cs_isIphone && cs_ScreenH >= 568.0)
#define cs_iPhone_6_or_more (cs_isIphone && cs_ScreenH >= 667.0)
#define cs_iPhone_6P_or_more (cs_isIphone && cs_ScreenH >= 736.0)

#define cs_DocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define cs_CachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define cs_LibaryPath [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define cs_TempPath NSTemporaryDirectory()


#define cs_ImageByName(name) [UIImage imageNamed:name]
#define cs_ImageFromPath(path) [UIImage imageWithContentsOfFile:path];
#define cs_ImageFromBundle(name, type) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type]];

#define cs_RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define cs_RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define cs_RGB2Color(rgb) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0 green:((float)((rgb & 0xFF00) >> 8))/255.0 blue:((float)(rgb & 0xFF))/255.0 alpha:1.0]
#define cs_RGBA2Color(rgb, a) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0 green:((float)((rgb & 0xFF00) >> 8))/255.0 blue:((float)(rgb & 0xFF))/255.0 alpha:a]

#define cs_UserDefaultSetObj(obj, key) {[[NSUserDefaults standardUserDefaults] setObject:obj forKey:key]; [[NSUserDefaults standardUserDefaults] synchronize];}
#define cs_UserDefaultGetObj(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define cs_StrFormat(format, args...) [NSString stringWithFormat:format, args]
#define cs_StrJoint(obj1, obj2, objInterval) [NSString stringWithFormat:@"%@%@%@", obj1?:@"", objInterval?:@"", obj2?:@""]
#define cs_StrTrim(str) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

//weakify & strongify
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

#pragma mark -
#pragma mark Public Method
#import <UIKit/UIKit.h>
static inline UIImage *cs_clipImageWithView(UIView *view) {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static inline UIImage *cs_clipImageWithViewRect(UIView *view, CGRect rect) {
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    [view drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#import <CommonCrypto/CommonDigest.h>
static inline NSString *cs_md5(NSString *string) {
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    if(string == nil || [string length] == 0) {
        return nil;
    }
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

/**
 *  Fetch uuid as the unique identify
 */
static inline NSString *cs_uuid() {
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    //CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    CFRelease(uuidObject);
    return uuidStr;
}

/**
 *  To judge whether the string is null
 */
static inline BOOL cs_strNull(NSString *string) {
    if (!string) {
        return YES;
    }
    if (!([string isKindOfClass:[NSString class]] || [string isKindOfClass:[NSNumber class]])) {
        return YES;
    }
    NSString *str = [cs_StrTrim(cs_StrFormat(@"%@", string)) lowercaseString];
    if ([str isEqualToString:@""] ||
        [str isEqualToString:@"null"] ||
        [str isEqualToString:@"(null)"] ||
        [str isEqualToString:@"<null>"]) {
        return YES;
    }
    
    return NO;
}

static inline BOOL cs_addSkipBackupAttributeToItemAtPath(NSString *path) {
    NSURL *URL = [NSURL fileURLWithPath:path];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        
    }
    return success;
}

#import <ifaddrs.h>
#import <arpa/inet.h>
static inline NSString *cs_ipAddress() {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


#endif /* CSAppDefine_h */
