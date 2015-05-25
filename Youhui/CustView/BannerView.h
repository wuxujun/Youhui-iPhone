//
//  BannerView.h
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol BannerViewDelegate;

@interface BannerView : UIViewExtention
{
    
    UIImageView             *imageView;
    
    UIView                  *bgView;
    id<BannerViewDelegate>          delegate;
    
    NSDictionary                *dict;
}
@property (nonatomic,strong)NSDictionary    *dict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;


@end

@protocol BannerViewDelegate <NSObject>

@optional
-(void)onBannerViewClicked:(BannerView*)view;
@end
