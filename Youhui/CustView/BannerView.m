//
//  BannerView.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BannerView.h"
#import "UIImageView+AFNetworking.h"

@implementation BannerView
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
    self.backgroundColor=[UIColor whiteColor];
    
    imageView=[[UIImageView alloc]init];
    imageView.contentMode=UIViewContentModeScaleToFill;
    
    bgView=[[UIView alloc]init];
    [bgView setBackgroundColor:[UIColor grayColor]];
    [bgView setAlpha:0.6];
    
    [self addSubview:imageView];
    [self reAdjustLayout];
}

-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [imageView sizeToFit];
    [imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [bgView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

-(void)handelSingleTap:(UITapGestureRecognizer*)recognizer
{
    [self addSubview:bgView];
    [self performSelector:@selector(singleTap:) withObject:nil afterDelay:0.2];
    [self performSelector:@selector(clearViewColor:) withObject:nil afterDelay:0.6];
}

-(void)singleTap:(id)sender
{
    if ([delegate respondsToSelector:@selector(onBannerViewClicked:)]) {
        [delegate onBannerViewClicked:self];
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
            [imageView setImageWithURL:[NSURL URLWithString:[aDict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        }
    }
    [self setNeedsDisplay];
}
@end
