//
//  BaseViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BaseViewController.h"
#import "CityViewController.h"
#import "ScanSViewController.h"
#import "NoticeViewController.h"
#import "SIAlertView.h"
#import "LoginViewController.h"

@implementation BaseViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
//    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
//    }

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLogin:) name:@"Notification_OpenLogin" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-(BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

-(void)openLogin: (NSNotification*) aNotification
{
    LoginViewController* dController=[[LoginViewController alloc]init];
    [self.navigationController pushViewController:dController animated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(IBAction)openMessage:(id)sender
{
//    if (iOS_VERSION_7) {
//        ScanSViewController* dController=[[ScanSViewController alloc] init];
//        [self.navigationController pushViewController:dController animated:YES];
//    }
    NoticeViewController* dController=[[NoticeViewController alloc]init];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

-(IBAction)citySelect:(id)sender
{
    CityViewController* dController=[[CityViewController alloc]init];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

-(void)alertRequestResult:(NSString *)msg isPop:(BOOL)flag
{
    SIAlertView * aView=[[SIAlertView alloc]initWithTitle:nil andMessage:msg];
    [aView addButtonWithTitle:@"2秒后自动关闭" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        if (flag) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [aView show];
    double delayInSeconds=2.0;
    dispatch_time_t popTime=dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
    dispatch_after(popTime,dispatch_get_main_queue(),^(void){
        [aView dismissAnimated:YES];
        if (flag) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    });
}

-(void)alertRequestResult:(NSString *)msg isDisses:(BOOL)flag
{
    SIAlertView * aView=[[SIAlertView alloc]initWithTitle:nil andMessage:msg];
    [aView addButtonWithTitle:@"2秒后自动关闭" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        if (flag) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }];
    [aView show];
    double delayInSeconds=2.0;
    dispatch_time_t popTime=dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
    dispatch_after(popTime,dispatch_get_main_queue(),^(void){
        [aView dismissAnimated:YES];
        if (flag) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    });
}

@end
