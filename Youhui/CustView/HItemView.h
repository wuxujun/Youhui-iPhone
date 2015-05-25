//
//  HItemView.h
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol HItemViewDelegate;

@interface HItemView : UIViewExtention
{
    
    UIImageView                 *imageView;
    UIView                      *bgView;
    
    UILabel                     *brandLabel;
    UILabel                     *titleLabel;
    UIImageView                 *bgImage;
    
    id<HItemViewDelegate>       delegate;
    NSDictionary*               infoDict;
}

@property (nonatomic,strong)NSDictionary*   infoDict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;

@end


@protocol HItemViewDelegate <NSObject>

@optional
-(void)onHItemViewClicked:(NSDictionary*)dict;

@end
