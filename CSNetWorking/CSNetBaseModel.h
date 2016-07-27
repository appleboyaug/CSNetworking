//
//  CSNetBaseModel.h
//  CSTools
//
//  Created by feng jia on 16/1/11.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import <Foundation/Foundation.h>

//TODO: 定义属性时请不要定义nsnumber类型，否则copy时会出现问题
@interface CSNetBaseModel : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)memcpy:(char *)agePtr value:(NSNumber *)value;

- (NSString *)strForKey:(NSString *)key;
- (NSArray *)arrForKey:(NSString *)key;
- (NSDictionary *)dictForKey:(NSString *)key;
- (NSNumber *)numberForKey:(NSString *)key;

@end
