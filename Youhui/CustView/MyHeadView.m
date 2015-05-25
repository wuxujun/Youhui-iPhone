//
//  MyHeadView.m
//  Youhui
//
//  Created by xujunwu on 15/3/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MyHeadView.h"
#import "UIButton+Category.h"
#import <QuartzCore/QuartzCore.h>
#import "HCurrentUserContext.h"
#import "UserDefaultHelper.h"

@implementation MyHeadView


-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self=[super initWithFrame:frame];
    if (self) {
        delegate=aDelegate;
        [self initializedFields];
    }
    return self;
}

-(void)initializedFields
{
    bgView=[[UIImageView alloc]init];
    bgView.contentMode=UIViewContentModeScaleToFill;
    [bgView setImage:[UIImage imageNamed:@"item_bg"]];
    
    avatarView=[[UIImageView alloc]init];
    [avatarView setImage:[UIImage imageNamed:@"ic_normal"]];
    avatarView.layer.cornerRadius=50;
    avatarView.layer.masksToBounds=YES;
    [self addSubview:avatarView];
    
    loginBtn=[[UIButton alloc]init];
    [loginBtn primaryStyle];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:loginBtn];
    
    registerBtn=[[UIButton alloc]init];
    [registerBtn primaryStyle];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:registerBtn];
    
    cellButton=[[UIButton alloc]init];
    [cellButton addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    
    
    userLabel=[[UILabel alloc]init];
    [userLabel setTextColor:[UIColor whiteColor]];
    [userLabel setFont:[UIFont boldSystemFontOfSize:28.0f]];
    [self addSubview:userLabel];
    
    cityLabel=[[UILabel alloc]init];
    [cityLabel setTextColor:[UIColor whiteColor]];
    
    [self addSubview:cityLabel];
    [self addSubview:cellButton];
    
    [self addSubview:bgView];
    [self reAdjustLayout];
}

-(IBAction)login:(id)sender
{
    if ([delegate respondsToSelector:@selector(onMyHeadViewLoginClicked)]) {
        [delegate onMyHeadViewLoginClicked];
    }
}

-(IBAction)reg:(id)sender
{
    if ([delegate respondsToSelector:@selector(onMyHeadViewRegisterClicked)]) {
        [delegate onMyHeadViewRegisterClicked];
    }
}

-(IBAction)open:(id)sender
{
    if ([delegate respondsToSelector:@selector(onMyHeadViewClicked)]) {
        [delegate onMyHeadViewClicked];
    }
}
-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [bgView sizeToFit];
    [bgView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGSize areaSize=bgView.frame.size;
    float h=areaSize.height-50;
    if ([[HCurrentUserContext sharedInstance] uid]) {
        [userLabel setFrame:CGRectMake(120, 50, areaSize.width-140, 40)];
        [cityLabel setFrame:CGRectMake(120, 80, areaSize.width-140, 40)];
        [avatarView setFrame:CGRectMake(10, 25, 100, 100)];
        [cellButton setFrame:bgView.frame];
    }else{
        [avatarView setFrame:CGRectMake((areaSize.width-h)/2, 5, h, h)];
        [loginBtn setFrame:CGRectMake((areaSize.width/2-100)/2, areaSize.height-40, 100, 36)];
        [registerBtn setFrame:CGRectMake((areaSize.width/2-100)/2+areaSize.width/2, areaSize.height-40, 100, 36)];
    }
}

-(void)refresh
{
    if ([[HCurrentUserContext sharedInstance] username]) {
        if ([UserDefaultHelper objectForKey:@"user_nick"]) {
            [userLabel setText:[UserDefaultHelper objectForKey:@"user_nick"]];
        }else{
            [userLabel setText:[[HCurrentUserContext sharedInstance] username]];
        }
       
    }
    
    if ([[UserDefaultHelper objectForKey:@"user_avatar_url"] length]>0) {
        DLog(@"%@",[UserDefaultHelper objectForKey:@"user_avatar_url"]);
        [avatarView setImage:[UIImage imageNamed:[UserDefaultHelper objectForKey:@"user_avatar_url"]]];
    }
    [self reAdjustLayout];
    [loginBtn setHidden:YES];
    [registerBtn setHidden:YES];
    [cellButton setHidden:NO];
    [self setNeedsDisplay];
}

-(void)logout
{
    [userLabel setText:@""];
    [avatarView setImage:[UIImage imageNamed:@"ic_normal"]];
    [loginBtn setHidden:NO];
    [registerBtn setHidden:NO];
    [cellButton setHidden:YES];
    [self reAdjustLayout];
}

@end
