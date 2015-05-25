//
//  BrandFootView.m
//  Youhui
//
//  Created by xujunwu on 15/4/2.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BrandFootView.h"
#import "UIImageView+AFNetworking.h"
#import "CollectEntity.h"

@implementation BrandFootView
@synthesize dict;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        [self initializeFields];
        
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    bgView=[[UIImageView alloc]  init];
    [bgView setImage:[UIImage imageNamed:@"ic_nav_bg"]];
    [contentView addSubview:bgView];
    
    shareBtn=[[UIButton alloc] init];
    [shareBtn setTag:0];
    [shareBtn addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    shareIV=[[UIImageView alloc]init];
    [shareIV setImage:[UIImage imageNamed:@"ic_share"]];
    [shareBtn addSubview:shareIV];
    
    shareLB=[[UILabel alloc]init];
    shareLB.font=[UIFont systemFontOfSize:16.0f];
    shareLB.textColor=[UIColor whiteColor];
    shareLB.text=@"分享";
    [shareBtn addSubview:shareLB];
    [contentView addSubview:shareBtn];
    
    telBg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tabbar_main_bg"]];
    [contentView addSubview:telBg];
    
    telBtn=[[UIButton alloc] init];
    [telBtn setTag:1];
    [telBtn setImage:[UIImage imageNamed:@"ic_call"] forState:UIControlStateNormal];
//    [telBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [telBtn addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:telBtn];
    
    favBtn=[[UIButton alloc] init];
    [favBtn setTag:2];
    [favBtn addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    favLB=[[UILabel alloc]init];
    favLB.font=[UIFont systemFontOfSize:16.0f];
    favLB.textColor=[UIColor whiteColor];
    favLB.text=@"收藏";
    [favBtn addSubview:favLB];
    
    
    favIV=[[UIImageView alloc]init];
    [favIV setImage:[UIImage imageNamed:@"ic_fav"]];
    [favBtn addSubview:favIV];
    
    [contentView addSubview:favBtn];
    
    [self addSubview:contentView];
    [self reAdjustLayout];
}

-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CGSize areaSize=contentView.frame.size;
    [bgView sizeToFit];
    [bgView setFrame:CGRectMake(0, 0, areaSize.width, areaSize.height)];

    float w=areaSize.width/3;
    
    [shareBtn setFrame:CGRectMake(0, 0, w, areaSize.height)];
    [shareIV setFrame:CGRectMake((w-66)/2+5, (49-26)/2, 26, 26)];
    [shareLB setFrame:CGRectMake((w-66)/2+36, (49-30)/2, 50, 30)];
    
    [telBg setFrame:CGRectMake((areaSize.width-56)/2, -6, 56, 56)];
    [telBtn setFrame:CGRectMake((areaSize.width-50)/2, -2, 50, 50)];
    
    
    [favBtn setFrame:CGRectMake(w*2,0, w, areaSize.height)];
    [favLB setFrame:CGRectMake((w-66)/2+30, (49-30)/2, 50, 30)];
    [favIV setFrame:CGRectMake((w-66)/2, (49-26)/2, 26, 26)];
}

-(IBAction)onClicked:(id)sender
{
    DLog(@"call");
    if ([delegate respondsToSelector:@selector(onBrandFootViewClicked:)]) {
        [delegate onBrandFootViewClicked:[((UIButton*)sender) tag]];
    }
}

-(void)setDict:(NSDictionary *)aDict
{
    dict=aDict;
    if (dict) {
        
    }
    [self setNeedsDisplay];
}

-(void)isCollect:(BOOL)flag
{
    if (flag) {
        [favIV setImage:[UIImage imageNamed:@"ic_fav_sel"]];
    }else{
        [favIV setImage:[UIImage imageNamed:@"ic_fav"]];
    }
    [self setNeedsDisplay];
}

@end
