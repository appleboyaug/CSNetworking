//
//  ViewController.m
//  CSTools
//
//  Created by feng jia on 16/1/9.
//  Copyright © 2016年 caishi. All rights reserved.
//

#import "ViewController.h"
#import "CSNetClient.h"
#import "T1.h"
//#import "CSAppDefine.h"

#define strJoin(str, args...)  [NSString stringWithFormat:str, args]

@interface ViewController ()

@end

NSString *extStr;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    strJoin(@"%@, %@", @"d", @",");
//    cs_StrFormat(@"%d, %@", 3, @"s");
//    cs_StrJoint(@9, @9, @9);
    
//    NSLog(@"%@", cs_ipAddress());
//    NSLog(@"%@", cs_uuid());
//    NSLog(@"%@", cs_StrJoint(@"welcom", @"china", nil));
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"login" ofType:@"cer"];
    
    [CSNetClient setDefaultSSLSurpport:YES certificatePaths:path];
    //http://api.9liuda.com/v1/channel/list?version=0
    CSNetRequestConfiguration *config = [[CSNetRequestConfiguration alloc] initWithHost:nil];
    
//    config.host = @"https://api.365liuda.com/";
//    config.path = @"/v1/channel/list?";
    
    config.host = @"http://login.365liuda.com/";
    config.path = @"v1/user/register/device";
    config.returnType = ARRAY;
    config.modelCla = [T1 class];
    config.retryTime = 2;
    NSDictionary *dict = nil;//@{@"version": @(0)};
    
    [[CSNetClient instance] cs_get:config parameter:dict completeHandler:^(id responseData, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"%@", responseData);
        }
    }];
//    [[CSNetClient instance] cancelByRequestPath:config.path];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
