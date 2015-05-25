//
//  HTabBarViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/12.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "HTabBarViewController.h"
#import "HTabBarView.h"
#import "HomeViewController.h"
#import "MyViewController.h"
#import "CRNavigationController.h"

#define SELECTED_VIEW_CONTROLLER_TAG  123890

@interface HTabBarViewController()
{
    CGFloat         orginHeight;
    CGFloat         tabHeight;
    BOOL            bShow;
}
@end

@implementation HTabBarViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    bShow=YES;
    tabHeight=49.0;
    orginHeight=self.view.frame.size.height-tabHeight;

    CGRect bounds=[[UIScreen mainScreen] bounds];
    DLog(@"%f  %f",bounds.size.width,bounds.size.height);
    self.tabbarView=[[HTabBarView alloc]initWithFrame:CGRectMake(0, orginHeight, self.view.bounds.size.width, tabHeight)];
    self.tabbarView.delegate=self;
    [self.view addSubview:self.tabbarView];
    
    _arrayViewController=[self getViewControllers];
    [self touchBtnAtIndex:0];
    
}

-(void)hidenTabbarView:(BOOL)isShow
{
    CGRect bounds=[[UIScreen mainScreen] bounds];
    DLog(@"==============> %f   %f   %f  %f",self.view.frame.size.width,self.view.frame.size.height,bounds.size.width,bounds.size.height);
    
    if (bShow&&isShow) {
        [self.tabbarView removeFromSuperview];
        [self.view setFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height+tabHeight)];
        bShow=NO;
    }else{
        if (!bShow) {
            [self.view addSubview:self.tabbarView];
            [self.view setFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
            bShow=YES;
        }
    }
     DLog(@"==============> %f   %f   %f  %f",self.view.frame.size.width,self.view.frame.size.height,bounds.size.width,bounds.size.height);
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)touchBtnAtIndex:(NSInteger)index
{
    UIView* currentView=[self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    [currentView removeFromSuperview];
    
    NSDictionary* data=[_arrayViewController objectAtIndex:index];
    CRNavigationController* viewController=data[@"viewController"];
    viewController.view.tag=SELECTED_VIEW_CONTROLLER_TAG;
    viewController.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-tabHeight);
    [self.view insertSubview:viewController.view belowSubview:self.tabbarView];
    
}
-(NSArray*)getViewControllers
{
    NSArray* tabBarItems=nil;
    CRNavigationController* homeController=[[CRNavigationController alloc] initWithRootViewController:[[HomeViewController alloc]init]];
    CRNavigationController*   myController=[[CRNavigationController alloc]initWithRootViewController:[[MyViewController alloc]init]];
    
    tabBarItems=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"Home",@"image",@"Home",@"image_lock",homeController,@"viewController",@"主页",@"title", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"My",@"image",@"My",@"image_lock",myController,@"viewController",@"我的",@"title", nil], nil];
    
    return tabBarItems;
}
@end
