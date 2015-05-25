//
//  AppDelegate.h
//  Youhui
//
//  Created by xujunwu on 15/1/29.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import "HNetworkEngine.h"
#import "CustomTabBarViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CustomTabBarViewController    *viewController;
@property (strong, nonatomic) HNetworkEngine*       networkEngine;

@property(nonatomic,strong)id<GAITracker>       tracker;

-(void)openMainView;

@end

