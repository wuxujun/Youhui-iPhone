//
//  MItemView.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MItemView.h"

#import "UIImageView+AFNetworking.h"

@implementation MItemView

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
    [self addSubview:imageView];
    titleBGView=[[UIImageView alloc]init];
    [titleBGView setImage:[[UIImage imageNamed:@"ic_map_title_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    [self addSubview:titleBGView];
    
    titleLabel=[[UILabel alloc]init];
    [titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:titleLabel];
    
    mapButton=[[UIButton alloc]init];
    [mapButton setImage:[UIImage imageNamed:@"ic_map_nav"] forState:UIControlStateNormal];
    [mapButton setImage:[UIImage imageNamed:@"ic_map_nav_selected"] forState:UIControlStateHighlighted];
    [self addSubview:mapButton];
    
    
    bgView=[[UIView alloc]init];
    [bgView setBackgroundColor:[UIColor grayColor]];
    [bgView setAlpha:0.6];
    
    
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
    CGSize areaSize=imageView.frame.size;
    
    [titleBGView setFrame:CGRectMake(0, areaSize.height-30, areaSize.width, 30)];
    [titleLabel setFrame:CGRectMake(10, areaSize.height-30, areaSize.width-40, 30)];
    [mapButton setFrame:CGRectMake(areaSize.width-25, areaSize.height-25, 20, 20)];
    
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
    if ([delegate respondsToSelector:@selector(onMItemViewClicked:)]) {
        [delegate onMItemViewClicked:self];
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
            [imageView setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_cell_normal"]];
        }
        if ([dict objectForKey:@"mallName"]) {
            [titleLabel setText:[NSString stringWithFormat:@"%@",[dict objectForKey:@"mallName"]]];
        }
    }
    [self setNeedsDisplay];
}
@end
