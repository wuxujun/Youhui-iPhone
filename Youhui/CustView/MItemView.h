//
//  MItemView.h
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol MItemViewDelegate;


@interface MItemView : UIViewExtention
{
    
    UIImageView                     *imageView;
    UILabel                         *titleLabel;
    UIImageView                     *titleBGView;
    UIButton                        *mapButton;
    
    UIView                          *bgView;
    id<MItemViewDelegate>           delegate;
    
    NSDictionary                    *dict;
}
@property (nonatomic,strong)NSDictionary    *dict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;

@end

@protocol MItemViewDelegate <NSObject>

@optional
-(void)onMItemViewClicked:(MItemView*)view;
@end