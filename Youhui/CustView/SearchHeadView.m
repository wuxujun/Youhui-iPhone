//
//  SearchHeadView.m
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "SearchHeadView.h"
#import "UserDefaultHelper.h"

@implementation SearchHeadView

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self=[super initWithFrame:frame];
    if (self) {
        delegate=aDelegate;
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    contentView=[[UIView alloc]init];
    contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    NSArray* array=(NSArray*)[UserDefaultHelper objectForKey:SEARCH_HOT_KEY];
    titleBG=[[UIView alloc]init];
    [titleBG setBackgroundColor:TABLE_BACKGROUND_COLOR];
    [contentView addSubview:titleBG];
    
    titleLabel=[[UILabel alloc]init];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor grayColor]];
    [titleLabel setText:@"热门搜索"];
    [contentView addSubview:titleLabel];
    
    btn0=[[UIButton alloc]init];
    [btn0 setTag:0];
    [btn0 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if ([array count]>0) {
        NSDictionary* dc=[array objectAtIndex:0];
        [btn0 setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
    }
    [btn0 customSearchStyle];
    [btn0 addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn0];
    
    btn1=[[UIButton alloc]init];
    [btn1 setTag:1];
    [btn1 customSearchStyle];
    if ([array count]>1) {
        NSDictionary* dc=[array objectAtIndex:1];
        [btn1 setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
    }
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn1];
    
    btn2=[[UIButton alloc]init];
    [btn2 setTag:2];
    [btn2 customSearchStyle];
    if ([array count]>2) {
        NSDictionary* dc=[array objectAtIndex:2];
        [btn2 setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
    }
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn2];
    
    btn3=[[UIButton alloc]init];
    [btn3 setTag:3];
    [btn3 customSearchStyle];
    if ([array count]>3) {
        NSDictionary* dc=[array objectAtIndex:3];
        [btn3 setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
    }
    [btn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn3];
    
    btn4=[[UIButton alloc]init];
    [btn4 setTag:4];
    [btn4 customSearchStyle];
    if ([array count]>4) {
        NSDictionary* dc=[array objectAtIndex:4];
        [btn4 setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
    }[btn4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn4];
    
    btn5=[[UIButton alloc]init];
    [btn5 setTag:5];
    [btn5 customSearchStyle];
    if ([array count]>5) {
        NSDictionary* dc=[array objectAtIndex:5];
        [btn5 setTitle:[dc objectForKey:@"title"] forState:UIControlStateNormal];
    }
    [btn5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn5 addTarget:self action:@selector(onBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn5];
    
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
    DLog(@"%@",btn0.titleLabel.text);
    [titleBG setFrame:CGRectMake(0, 0, areaSize.width, 40)];
    [titleLabel setFrame:CGRectMake(20, 0, areaSize.width-40, 40)];
    
    [btn0 setFrame:CGRectMake(5, 45, areaSize.width/2-10, 30)];
    [btn1 setFrame:CGRectMake(areaSize.width/2+25, 45, areaSize.width/2-50, 30)];
    [btn2 setFrame:CGRectMake(10, 85, areaSize.width/2-20, 30)];
    [btn3 setFrame:CGRectMake(areaSize.width/2+5, 85, areaSize.width/2-10, 30)];
    [btn4 setFrame:CGRectMake(20, 125, areaSize.width/2-40, 30)];
    [btn5 setFrame:CGRectMake(areaSize.width/2+20,125, areaSize.width/2-40, 30)];
}

-(void)setInfoDict:(NSDictionary *)aInfoDict
{
    infoDict=aInfoDict;
    [self setNeedsDisplay];
}


-(IBAction)onBtnClicked:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    if ([delegate respondsToSelector:@selector(onSearchHeadButtonClick:)]) {
        [delegate onSearchHeadButtonClick:btn.titleLabel.text];
    }
}

@end
