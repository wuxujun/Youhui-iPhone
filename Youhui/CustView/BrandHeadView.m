//
//  BrandHeadView.m
//  Youhui
//
//  Created by xujunwu on 15/3/21.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BrandHeadView.h"
#import "UIImageView+AFNetworking.h"

@implementation BrandHeadView
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
    contentView=[[UIView alloc]init];
    contentView.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    
    imageView=[[UIImageView alloc]init];
    [contentView addSubview:imageView];
    
    
    titleLB=[[UILabel alloc]init];
    titleLB.font=[UIFont systemFontOfSize:18.0f];
    titleLB.textColor=[UIColor whiteColor];
    titleLB.numberOfLines=0;
    [contentView addSubview:titleLB];
    
    cateLB=[[UILabel alloc]init];
    cateLB.font=[UIFont systemFontOfSize:14.0f];
    cateLB.textColor=[UIColor grayColor];
//    [contentView addSubview:cateLB];
    rating=[[HTapRateView alloc]init];
    [rating setMax_star:5];
    [contentView addSubview:rating];
    
    
    addressLB=[[UILabel alloc]init];
    addressLB.font=[UIFont systemFontOfSize:16.0];
    addressLB.textColor=[UIColor whiteColor];
    
    [contentView addSubview:addressLB];
    
    telLB=[[UILabel alloc]init];
    telLB.font=[UIFont systemFontOfSize:16.0];
    telLB.textColor=[UIColor whiteColor];
    [contentView addSubview:telLB];
    
//    favLB=[[UILabel alloc]init];
//    favLB.font=[UIFont systemFontOfSize:14];
//    favLB.textColor=[UIColor whiteColor];
//    favLB.text=@"收藏";
//    [contentView addSubview:favLB];
    
//    favBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    [favBtn setImage:[UIImage imageNamed:@"ic_fav"] forState:UIControlStateNormal];
//    [favBtn setImage:[UIImage imageNamed:@"ic_fav_sel"] forState:UIControlStateSelected];
//    [favBtn addTarget:self action:@selector(collect:) forControlEvents:UIControlEventTouchUpInside];
//    [contentView addSubview:favBtn];
    
    locIV=[[UIImageView alloc]init];
    [locIV setImage:[UIImage imageNamed:@"ic_loc"]];
    [contentView addSubview:locIV];
    telIV=[[UIImageView alloc]init];
    [telIV setImage:[UIImage imageNamed:@"ic_tel"]];
    [contentView addSubview:telIV];
    line1=[[UIView alloc]init];
    [line1 setBackgroundColor:TABLE_BACKGROUND_COLOR];
    [contentView addSubview:line1];
    
    line2=[[UIView alloc]init];
    [line2 setBackgroundColor:TABLE_BACKGROUND_COLOR];
    [contentView addSubview:line2];
    
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
    
    [imageView setFrame:CGRectMake(10, 7, 96, 96)];
    
    [titleLB setFrame:CGRectMake(120, 10, areaSize.width-130, 60)];
//    [cateLB setFrame:CGRectMake(120, 60, 150, 30)];
    [rating setFrame:CGRectMake(120, 70, 100, 30)];
    
//    [favBtn setFrame:CGRectMake(areaSize.width-50, 20, 26, 26)];
//    [favLB setFrame:CGRectMake(areaSize.width-50, 42, 50, 30)];
    
    [locIV setFrame:CGRectMake(10, 122, 26, 26)];
    [addressLB setFrame:CGRectMake(40, 122, areaSize.width-50, 30)];
    [telIV setFrame:CGRectMake(10, 166, 26, 26)];
    [telLB setFrame:CGRectMake(40, 166, 200, 30)];

    [line1 setFrame:CGRectMake(0, 115, areaSize.width, 1)];
    [line2 setFrame:CGRectMake(0, 157, areaSize.width, 1)];
}

-(IBAction)collect:(id)sender
{
    
}

-(void)handelSingleTap:(UITapGestureRecognizer*)recognizer
{
    [self performSelector:@selector(singleTap:) withObject:nil afterDelay:0.2];
}

-(void)singleTap:(id)sender
{
    if ([delegate respondsToSelector:@selector(onBrandHeadViewClicked:)]) {
        [delegate onBrandHeadViewClicked:self];
    }
}

-(void)setDict:(NSDictionary *)aDict
{
    dict=aDict;
    if (dict) {
        if ([dict objectForKey:@"brandLogo"]) {
            [imageView setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        }
        if ([dict objectForKey:@"site"]) {
            [addressLB setText:[NSString stringWithFormat:@"%@%@%@",[dict objectForKey:@"mallName"],[dict objectForKey:@"floorName"],[dict objectForKey:@"site"]]];
        }
        
        if ([dict objectForKey:@"tel"]) {
            [telLB setText:[dict objectForKey:@"tel"]];
        }
    
        if ([dict objectForKey:@"cateName"]) {
            [cateLB setText:[dict objectForKey:@"cateName"]];
        }
        
        if ([dict objectForKey:@"brandName"]) {
            [titleLB setText:[dict objectForKey:@"brandName"]];
        }
        
        if ([dict objectForKey:@"rating"]) {
            [rating setShow_star:[[dict objectForKey:@"rating"] integerValue]];
        }
    }
    [self setNeedsDisplay];
}

@end
