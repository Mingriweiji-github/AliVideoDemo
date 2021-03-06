//
//  AppDelegate.m
//  AliVideoDemo
//
//  Created by Apple on 2019/5/22.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "AppDelegate.h"
#import "AliBaseNavigationController.h"
#import "ViewController.h"
#import "AlivcUIConfig.h"
#import "UIImage+AlivcHelper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //以下为录制
//    AliBaseNavigationController *nav = [[AliBaseNavigationController alloc] initWithRootViewController:[ViewController new]];
//    [self setBaseNavigationBar:nav];
//    self.window.rootViewController = nav;
    
    //以下为播放
    [AlivcImage setImageBundleName:@"AlivcShortVideoImage"];
    UIViewController *vc_root = [[NSClassFromString(@"AlivcShortVideoQuHomeTabBarController") alloc]init];
    UINavigationController *nav_root = [[UINavigationController alloc]initWithRootViewController:vc_root];
    self.window.rootViewController = nav_root;
    
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}
/**
 导航栏设置，全局有效
 */
- (void)setBaseNavigationBar:(UINavigationController *)nav{
    //
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [nav.navigationBar setBackgroundImage:[UIImage avc_imageWithColor:[AlivcUIConfig shared].kAVCBackgroundColor] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setShadowImage:[UIImage new]];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
