//
//  AppDelegate.m
//  MessageForwardDemo
//
//  Created by 李敏 on 2021/9/5.
//  Copyright © 2021 李敏. All rights reserved.
//  消息转发 参照博客为[iOS开发·runtime原理与实践: 消息转发篇](https://juejin.cn/post/6844903600968171533)

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *vc = [[ViewController alloc]init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    return YES;
}



@end
