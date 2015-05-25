//
//  BrandHeadView.h
//  Youhui
//
//  Created by xujunwu on 15/3/21.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "UIViewExtention.h"
#import "HTapRateView.h"

@protocol BrandHeadViewDelegate;

@interface BrandHeadView : UIViewExtention
{
    UIView              *contentView;
    
    UIImageView         *imageView;
    
    UILabel             *titleLB;
    HTapRateView        *rating;
    
    UILabel             *cateLB;
    
    UIImageView         *locIV;
    UIImageView         *telIV;
    
    UILabel             *addressLB;
    UILabel             *telLB;
    
    
    UIButton            *favBtn;
    UILabel             *favLB;
    UIView              *line1;
    UIView              *line2;
    
    
    id<BrandHeadViewDelegate>       delegate;
    NSDictionary*                   dict;
}

@property(nonatomic,strong)NSDictionary*     dict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
-(void)initializeFields;
@end


@protocol BrandHeadViewDelegate <NSObject>

@optional
-(void)onBrandHeadViewClicked:(BrandHeadView*)view;

@end