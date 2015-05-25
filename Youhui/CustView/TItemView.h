//
//  TItemView.h
//  Youhui
//
//  Created by xujunwu on 15/3/31.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol TItemViewDelegate;

@interface TItemView : UIViewExtention
{
    UIView                          *contentView;
    
    UIImageView                     *imageView;
    UILabel                         *titleLabel;
    UIImageView                     *titleBGView;
    UIButton                        *mapButton;
    
    UIView                          *bgView;
    id<TItemViewDelegate>           delegate;
    
    NSDictionary                    *dict;
}
@property (nonatomic,strong)NSDictionary    *dict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;

@end

@protocol TItemViewDelegate <NSObject>

@optional
-(void)onTItemViewClicked:(TItemView*)view;
@end

