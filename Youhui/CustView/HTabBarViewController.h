//
//  HTabBarViewController.h
//  Youhui
//
//  Created by xujunwu on 15/4/12.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HTabBarDelegate <NSObject>

-(void)touchBtnAtIndex:(NSInteger)index;

@end

@class HTabBarView;

@interface HTabBarViewController : UIViewController<HTabBarDelegate>

@property(nonatomic,strong)HTabBarView* tabbarView;
@property(nonatomic,strong)NSArray* arrayViewController;


-(void)hidenTabbarView:(BOOL)isShow;


@end
