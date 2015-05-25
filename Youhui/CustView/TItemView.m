//
//  TItemView.m
//  Youhui
//
//  Created by xujunwu on 15/3/31.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "TItemView.h"
#import "UIImageView+AFNetworking.h"

@implementation TItemView
@synthesize dict;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        [self initializeFields];
        
        UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelSingleTap:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:tapRecognizer];
        
    }
    return self;
}

-(void)initializeFields
{
    self.backgroundColor=[UIColor clearColor];
    contentView=[[UIView alloc]init];
    [contentView setBackgroundColor:[UIColor clearColor]];
    [contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    imageView=[[UIImageView alloc]init];
    imageView.contentMode=UIViewContentModeScaleToFill;
    [contentView addSubview:imageView];
    titleBGView=[[UIImageView alloc]init];
    [titleBGView setImage:[[UIImage imageNamed:@"ic_map_title_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    [contentView addSubview:titleBGView];
    
    titleLabel=[[UILabel alloc]init];
    [titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [contentView addSubview:titleLabel];
    
    mapButton=[[UIButton alloc]init];
    [mapButton setImage:[UIImage imageNamed:@"ic_map_nav"] forState:UIControlStateNormal];
    [mapButton setImage:[UIImage imageNamed:@"ic_map_nav_selected"] forState:UIControlStateHighlighted];
//    [self addSubview:mapButton];
    
    
    bgView=[[UIView alloc]init];
    [bgView setBackgroundColor:[UIColor grayColor]];
    [bgView setAlpha:0.6];
    
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
    CGSize areaSize=CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    
//    [imageView sizeToFit];
    [imageView setFrame:CGRectMake(5, 10, areaSize.width-10, areaSize.height-10)];
    
    [titleBGView setFrame:CGRectMake(5, areaSize.height-20, areaSize.width-10, 30)];
    [titleLabel setFrame:CGRectMake(10, areaSize.height-20, areaSize.width-20, 30)];
//    [mapButton setFrame:CGRectMake(areaSize.width-25, areaSize.height-25, 20, 20)];
    
    [bgView setFrame:CGRectMake(5, 0, self.frame.size.width, self.frame.size.height)];
}

-(void)handelSingleTap:(UITapGestureRecognizer*)recognizer
{
    [self addSubview:bgView];
    [self performSelector:@selector(singleTap:) withObject:nil afterDelay:0.2];
    [self performSelector:@selector(clearViewColor:) withObject:nil afterDelay:0.6];
}

-(void)singleTap:(id)sender
{
    if ([delegate respondsToSelector:@selector(onTItemViewClicked:)]) {
        [delegate onTItemViewClicked:self];
    }
}

-(void)clearViewColor:(id)sender
{
    [bgView removeFromSuperview];
    [self setNeedsDisplay];
}

-(void)setDict:(NSDictionary *)aDict
{
    dict=aDict;
    if (dict) {
        if ([dict objectForKey:@"image"]) {
            [imageView setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        }
        if ([dict objectForKey:@"title"]) {
            [titleLabel setText:[NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]]];
        }
    }
    [self setNeedsDisplay];
}
@end
