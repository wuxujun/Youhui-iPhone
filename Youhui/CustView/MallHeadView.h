//
//  MallHeadView.h
//  Youhui
//
//  Created by xujunwu on 15/2/9.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExtention.h"

@protocol MallHeadViewDelegate;

@interface MallHeadView : UIViewExtention
{
    UIView                          *contentView;
    
    UILabel                         *mapLabel;
    UIImageView                     *mapImage;
    UIButton                            *mapBtn;
    UILabel                         *cateLabel;
    UIImageView                     *cateImage;
    UIButton                            *cateBtn;
    UILabel                         *floorLabel;
    UIImageView                     *floorImage;
    UIButton                            *floorBtn;
    
    id<MallHeadViewDelegate>           delegate;
    
    NSDictionary                    *dict;
}
@property (nonatomic,strong)NSDictionary    *dict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;

@end


@protocol MallHeadViewDelegate <NSObject>

@optional
-(void)onMallHeadViewClicked:(int)type;
@end