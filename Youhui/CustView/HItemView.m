//
//  HItemView.m
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "HItemView.h"
#import "UIImageView+AFNetworking.h"


@implementation HItemView
@synthesize infoDict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self=[super initWithFrame:frame];
    if (self) {
        delegate=aDelegate;
        
        [self initializeFields];
//        UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelSingleTap:)];
//        [tapRecognizer setNumberOfTapsRequired:1];
//        [tapRecognizer setNumberOfTouchesRequired:1];
//        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

-(void)initializeFields
{
    imageView=[[UIImageView alloc]init];
    imageView.contentMode=UIViewContentModeScaleToFill;
    [self addSubview:imageView];
    
    bgView=[[UIView alloc]init];
    [bgView setBackgroundColor:[UIColor grayColor]];
    [bgView setAlpha:0.6];
    [self addSubview:bgView];
    
    bgImage=[[UIImageView alloc]init];
    [bgImage setImage:[[UIImage imageNamed:@"ic_map_title_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
//    [self addSubview:bgImage];
    
    brandLabel=[[UILabel alloc]init];
    [brandLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [brandLabel setTextColor:[UIColor whiteColor]];
    [brandLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:brandLabel];
    
    titleLabel=[[UILabel alloc]init];
    [titleLabel setFont:[UIFont systemFontOfSize:16]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel setNumberOfLines:0];
    [self addSubview:titleLabel];
    
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
//    [bgView setFrame:imageView.frame];
    [bgView setFrame:CGRectMake(areaSize.width*0.6,areaSize.height-80, areaSize.width*0.4, 60)];
//    [bgImage setFrame:CGRectMake(areaSize.width*0.6,areaSize.height-80, areaSize.width*0.4, 60)];
    [brandLabel setFrame:CGRectMake(areaSize.width*0.6, areaSize.height-80, areaSize.width*0.4, 30)];
    [titleLabel setFrame:CGRectMake(areaSize.width*0.6, areaSize.height-56, areaSize.width*0.4, 50)];
    
}

-(void)handelSingleTap:(UITapGestureRecognizer*)recognizer
{
//    [self addSubview:bgView];
    [self performSelector:@selector(singleTap:) withObject:nil afterDelay:0.2];
    [self performSelector:@selector(clearViewColor:) withObject:nil afterDelay:0.6];
}

-(void)singleTap:(id)sender
{
    if ([delegate respondsToSelector:@selector(onHItemViewClicked:)]) {
        [delegate onHItemViewClicked:infoDict];
    }
}

-(void)clearViewColor:(id)sender
{
    [self setNeedsDisplay];
}

-(void)setInfoDict:(NSDictionary *)aInfoDict
{
    infoDict=aInfoDict;
    if (infoDict) {
        if ([infoDict objectForKey:@"image"]) {
            [imageView setImageWithURL:[NSURL URLWithString:[infoDict objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_cell_normal"]];
        }
        if ([infoDict objectForKey:@"title"]) {
            [titleLabel setText:[infoDict objectForKey:@"title"]];
        }
        if ([infoDict objectForKey:@"brandName"]) {
            [brandLabel setText:[infoDict objectForKey:@"brandName"]];
        }
    }
    [self setNeedsDisplay];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [titleLabel setTextColor:[UIColor blackColor]];
    [brandLabel setTextColor:[UIColor blackColor]];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [bgView setBackgroundColor:[UIColor grayColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [brandLabel setTextColor:[UIColor whiteColor]];
    [self setNeedsDisplay];
    if ([delegate respondsToSelector:@selector(onHItemViewClicked:)]) {
        [delegate onHItemViewClicked:infoDict];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [bgView setBackgroundColor:[UIColor grayColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [brandLabel setTextColor:[UIColor whiteColor]];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [bgView setBackgroundColor:[UIColor grayColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [brandLabel setTextColor:[UIColor whiteColor]];
}

@end
