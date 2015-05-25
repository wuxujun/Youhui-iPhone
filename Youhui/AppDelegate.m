//
//  AppDelegate.m
//  Youhui
//
//  Created by xujunwu on 15/1/29.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "AppDelegate.h"
#import "CityEntity.h"
#import "CRNavigationController.h"
#import "HomeViewController.h"
#import "MyViewController.h"
#import "SaleViewController.h"
#import "MapViewController.h"
#import "WealViewController.h"
#import "MyViewController.h"
#import "UserDefaultHelper.h"
#import "StartViewController.h"

#import "MobClick.h"
#import "UMSocial.h"
#import "UMessage.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.H"

#import <MAMapKit/MAMapKit.h>

#import <GoogleAnalytics-iOS-SDK/GAIFields.h> 
#import <GoogleAnalytics-iOS-SDK/GAITracker.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#import <SMS_SDK/SMS_SDK.h>

#define PUSHTYPE @"type"
#define PUSHTYPENEWS @"1"
#define PUSHTYPEPRIVNOTICE @"2"
#define PUSHTYPEDATAUPDATE @"3"
#define PUSHOBJECTID @"id"
#define PUSHOBJECTIITLE @"title"
#define PUSHOBJECTIIME @"sendtime"

#define PUSHPRIVNOTICEFROMID @"formuid"
#define PUSHPRIVNOTICEFNICKNAME @"nickname"

static NSString *const kTrackingId=@"UA-30968675-6";
static NSString *const kAllowTracking=@"allowTracking";


static NSString* const kSqlData=@"youhui.dat";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSDictionary *appDefault=@{kAllowTracking:@(YES)};
    [[NSUserDefaults standardUserDefaults]registerDefaults:appDefault];
    [GAI sharedInstance].optOut=![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    [GAI sharedInstance].dispatchInterval=20;
    //    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [GAI sharedInstance].trackUncaughtExceptions=YES;
    self.tracker=[[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"Youhui"];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView]build]];
    
    
    [UserDefaultHelper setObject:[OpenUDID value] forKey:DEVICE_IMEI];
    
    self.networkEngine =  [[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * path=[paths objectAtIndex:0];
    [MagicalRecord setupCoreDataStackWithStoreAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",path,kSqlData]]];
    
    
    [UMessage startWithAppkey:@"54f14debfd98c5361e000979" launchOptions:launchOptions];
   
    
    [UMessage setLogEnabled:YES];
    
    [SMS_SDK    registerApp:kSMS_SDK_AppKey withSecret:kSMS_SDK_AppSecret];
    
    if (IOS_VERSION_8) {
        if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
            [UMessage registerRemoteNotificationAndUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert) categories:nil]];
            
            
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound|UIUserNotificationTypeBadge|UIUserNotificationTypeAlert) categories:nil]];
            [application registerForRemoteNotifications];
            
        }
    }else{
         [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
//    NSDictionary* remoteUserInfo=launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (remoteUserInfo) {
//        NSString* type=[NSString stringWithFormat:@"%@",[remoteUserInfo objectForKey:PUSHTYPE]];
//        if ([type isEqualToString:PUSHTYPEDATAUPDATE]) {
//            ;
//        }
//    }
    
//    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    DLog(@"[familyNames count]===%d",[familyNames count]);
//    for(indFamily=0;indFamily<[familyNames count];++indFamily)
//        
//    {
//        DLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
//        for(indFont=0; indFont<[fontNames count]; ++indFont)
//            
//        {
//            DLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
//        }
//    }
    
    [UMSocialData setAppKey:@"54f14debfd98c5361e000979"];
    [self initializeData];
    [MobClick startWithAppkey:@"54f14debfd98c5361e000979" reportPolicy:BATCH channelId:@""];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ic_nav_bg"] forBarMetrics:UIBarMetricsDefault];
    
    [NSThread sleepForTimeInterval:2.0];
    
    UITabBarController* tabBarController=[[UITabBarController alloc]init];
    [tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"ic_tab_bg"]];
    self.viewController=tabBarController;
    self.window.rootViewController=tabBarController;
    [self.window makeKeyAndVisible];
    DLog(@"=======> %f  %f",tabBarController.tabBar.frame.size.height,[[tabBarController.tabBar backgroundImage] size].height);
    UIColor* navigationTextColor=RGBCOLOR(188, 117, 255);
    self.window.tintColor=navigationTextColor;
    
//    NSArray* viewControllers=@[[[CRNavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]],[[CRNavigationController alloc]initWithRootViewController:[[SaleViewController alloc]init]],[[CRNavigationController alloc]initWithRootViewController:[[MapViewController alloc]init]],[[CRNavigationController alloc]initWithRootViewController:[[MyViewController alloc]init]]];
    NSArray* viewControllers=@[[[CRNavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]],[[CRNavigationController alloc]initWithRootViewController:[[MyViewController alloc]init]]];
    tabBarController.viewControllers=viewControllers;
    
//    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"item_bar.png"]];
//    StartViewController* dController=[[StartViewController alloc]init];
//    [self.window setRootViewController:dController];
//    [self.window makeKeyAndVisible];

    return YES;
}

-(void)initializeData
{
    
    [MAMapServices sharedServices].apiKey=kAMAP_AppKey;
    
    [CityEntity MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES]];
    
    NSString *url = [NSString stringWithFormat:@"%@city",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"status", nil]];
    DLog(@"%@",params);
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        for (NSDictionary *dic in arr) {
            NSString* code=[dic objectForKey:@"areaCode"];
            NSArray *ds=[CityEntity MR_findByAttribute:@"code" withValue:code];
            if ([ds count]>0) {
                
            }else
            {
                CityEntity *entity=[CityEntity MR_createEntity];
                [entity setCode:[dic objectForKey:@"areaCode"]];
                [entity setTitle:[dic objectForKey:@"cityName"]];
                DLog(@"%@  %@",entity.code,entity.title);
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                if (contextDidSave) {
                    DLog(@"%d",contextDidSave);
                }
                
            }];
        }
        
        [ApplicationDelegate openMainView];
    } error:^(NSError *error) {
        DLog(@"post deviceToken fail");
    }];
    
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialWechatHandler setWXAppId:@"wxd930ea5d5a258f4f" appSecret:@"db426a9829e4b49a0dcac7b4162da6b6" url:@"http://www.umeng.com/social"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    application.applicationIconBadgeNumber=0;
    
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Youhui" action:@"Close" label:@"Close Youhui" value:[NSNumber numberWithInt:2]] build]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [GAI sharedInstance].optOut=![[NSUserDefaults standardUserDefaults]boolForKey:kAllowTracking];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Youhui" action:@"Open" label:@"Open Youhui" value:[NSNumber numberWithInt:1]] build]];
    
    [MobClick checkUpdate];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    application.applicationIconBadgeNumber=0;
}
#ifdef __IPHONE_8_0
-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"declineAction"]) {
        DLog(@"declineAction ..");
    }else if([identifier isEqualToString:@"answerAction"]){
        DLog(@"answerAction  ..");
    }
}
#endif

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLog(@"%@",error);
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //每次打开程序都会发送deviceToken,将device token转换为字符串
    [UMessage registerDeviceToken:deviceToken];
    
    NSString *deviceTokenStr = [NSString stringWithFormat:@"%@",deviceToken];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    DLog(@"%@ %lu",deviceTokenStr,(unsigned long)deviceTokenStr.length);
    [UserDefaultHelper setObject:deviceTokenStr forKey:DEVICE_TOKEN_UUID];
    NSString *url = [NSString stringWithFormat:@"%@uuid",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:deviceTokenStr,@"uuid",@"0",@"status", nil]];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        DLog(@"post deviceToken success");
    } error:^(NSError *error) {
        DLog(@"post deviceToken fail");
    }];
    
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMessage didReceiveRemoteNotification:userInfo];
    
//    NSString * type = [NSString stringWithFormat:@"%@",[userInfo objectForKey:PUSHTYPE]];//非字符串类型 转成NSString
//    if (application.applicationState != UIApplicationStateActive) {
//        if([type isEqualToString:PUSHTYPENEWS]) {//判断是否是 资讯 类型
//            NSDictionary *data = [userInfo objectForKey:@"data"];
//            NSString * newsId = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHOBJECTID]];
//            NSString * title = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHOBJECTIITLE]];
//            NSString * time = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHOBJECTIIME]];
//            if(newsId.length>0 && title.length > 0)
//            {
//                //设置程序图标上的数字。当为0时 通知中心将会自动清空该程序的所有消息
////                [self pushNewsDetailWithNewsId:newsId withTitle:title withTime:time];
//            }
//        } else if ([type isEqualToString:PUSHTYPEPRIVNOTICE]) {
//            //私信
//            NSDictionary *data = [userInfo objectForKey:@"data"];
//            NSString * fromId = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHPRIVNOTICEFROMID]];
//            NSString * nickname = [NSString stringWithFormat:@"%@",[data objectForKey:PUSHPRIVNOTICEFNICKNAME]];
//            if(fromId.length>0 && nickname.length > 0)
//            {
//                //设置程序图标上的数字。当为0时 通知中心将会自动清空该程序的所有消息
////                [self pushPrivChatViewWithUid:fromId withNickname:nickname];
//            }
//        }else if([type isEqualToString:PUSHTYPEDATAUPDATE]) {
////            [self updateData];
//        }
//    }else{
//        if ([type isEqualToString:PUSHTYPEDATAUPDATE]) {
////            [UIHelper showAlertViewWithMessage:@"有新的数据包，是否更新?" callback:^{
////                [self updateData];
////            }];
//        }
//    }
    
}


-(void)openMainView
{
    for (UIView* view in self.window.subviews) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    self.viewController=[[CustomTabBarViewController alloc]init];
    [self.viewController.tabBar setBackgroundImage:[UIImage imageNamed:@"ic_tab_bg"]];
//    UITabBarController* tabBarController=[[UITabBarController alloc]init];
//    [tabBarController.tabBar setBarStyle:UIBarStyleBlack];
//    [tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"ic_tab_bg"]];
//    self.viewController=tabBarController;
    self.window.rootViewController=self.viewController;
    [self.window makeKeyAndVisible];
    
    UIColor* navigationTextColor=RGBCOLOR(188, 117, 255);
    self.window.tintColor=navigationTextColor;
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:navigationTextColor}];
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ic_nav_bg"] forBarMetrics:UIBarMetricsDefault];
    
//    NSArray* viewControllers=@[[[CRNavigationController alloc]initWithRootViewController:[[HomeViewController alloc]init]],[[CRNavigationController alloc]initWithRootViewController:[[MyViewController alloc]init]]];
//    tabBarController.viewControllers=viewControllers;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

@end
