//
//  HTabBarView.m
//  Youhui
//
//  Created by xujunwu on 15/4/11.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "HTabBarView.h"

@implementation HTabBarView
-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
        [self layoutView];
    }
    return self;
}

-(void)layoutView
{
    CGRect bounds=[[UIScreen mainScreen] bounds];
    NSString* tabImg=@"tabbar_0";
    if (bounds.size.width==414) {
        tabImg=@"tabbar_0";
    }
    _tabbarView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:tabImg]];
    [_tabbarView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [_tabbarView setUserInteractionEnabled:YES];
    
    DLog(@"%f  %f",self.frame.size.height,self.bounds.size.height);
    NSString* tabImg1=@"tabbar_main_bg";
    if (bounds.size.width==414) {
        tabImg1=@"tabbar_main_bg";
    }
    _tabbarViewCenter=[[UIImageView alloc]initWithImage:[UIImage imageNamed:tabImg1]];
 
    DLog(@"%f   %f",self.center.x,self.bounds.size.height/2);
    _tabbarViewCenter.center=CGPointMake(self.center.x, self.bounds.size.height/2.0);
    
    [_tabbarViewCenter setUserInteractionEnabled:YES];

    NSString* tabImg2=@"tabbar_main";
    if (bounds.size.width==414) {
        tabImg2=@"tabbar_main";
    }
    _navBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _navBtn.adjustsImageWhenHighlighted=YES;
    [_navBtn setBackgroundImage:[UIImage imageNamed:tabImg2] forState:UIControlStateNormal];
    [_navBtn setFrame:CGRectMake(0, 0, 46, 46)];
    _navBtn.center=CGPointMake(_tabbarViewCenter.bounds.size.width/2.0, _tabbarViewCenter.bounds.size.height/2.0);
    
    [_tabbarViewCenter addSubview:_navBtn];
    
    [self addSubview:_tabbarView];
    [self addSubview:_tabbarViewCenter];
    [self layoutBtn];
}


-(void)layoutBtn
{
    _homeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_homeBtn setFrame:CGRectMake(0, 0, 200, self.bounds.size.height)];
    [_homeBtn setTag:101];
    [_homeBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _myBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [_myBtn setFrame:CGRectMake(self.frame.size.width-200, 0, 200, self.bounds.size.height)];
    [_myBtn setTag:102];
    [_myBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_tabbarView addSubview:_homeBtn];
    [_tabbarView addSubview:_myBtn];
}

-(void)btnClicked:(id)sender
{
    CGRect bounds=[[UIScreen mainScreen] bounds];
    UIButton* btn=(UIButton*)sender;
    switch (btn.tag) {
        case 101:
        {
            NSString* tabImg=@"tabbar_0";
            if (bounds.size.width==414) {
                tabImg=@"tabbar_0";
            }
            
            [_tabbarView setImage:[UIImage imageNamed:tabImg]];
            [self.delegate touchBtnAtIndex:0];
            break;
        }
        case 102:
        {
            NSString* tabImg=@"tabbar_1";
            if (bounds.size.width==414) {
                tabImg=@"tabbar_1";
            }
            [_tabbarView setImage:[UIImage imageNamed:tabImg]];
            [self.delegate touchBtnAtIndex:1];
            break;
        }
        default:
            break;
    }
}

@end
