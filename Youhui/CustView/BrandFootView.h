//
//  BrandFootView.h
//  Youhui
//
//  Created by xujunwu on 15/4/2.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExtention.h"

@protocol BrandFootViewDelegate;
@interface BrandFootView : UIViewExtention
{
    UIView         *contentView;
    UIImageView         *bgView;
    
    UIImageView         *shareIV;
    UILabel             *shareLB;
    UIButton            *shareBtn;

    UIImageView         *telBg;
    UIButton            *telBtn;
    
    UIImageView         *favIV;
    UILabel             *favLB;
    UIButton            *favBtn;
    
    id<BrandFootViewDelegate>           delegate;
    
}
@property(nonatomic,strong)NSDictionary*     dict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
-(void)initializeFields;

-(void)isCollect:(BOOL)flag;

@end


@protocol BrandFootViewDelegate <NSObject>

@optional
-(void)onBrandFootViewClicked:(int)type;
@end
