//
//  HTabBarView.h
//  Youhui
//
//  Created by xujunwu on 15/4/11.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTabBarViewController.h"

@interface HTabBarView : UIView
@property (nonatomic,strong)UIImageView         *tabbarView;
@property (nonatomic,strong)UIImageView         *tabbarViewCenter;
@property (nonatomic,strong)UIButton            *homeBtn;
@property (nonatomic,strong)UIButton            *myBtn;
@property (nonatomic,strong)UIButton            *navBtn;

@property (nonatomic,weak)id<HTabBarDelegate>   delegate;

@end
