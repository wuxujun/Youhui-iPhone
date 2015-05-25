//
//  SearchHeadView.h
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "UIViewExtention.h"
#import "UIButton+Category.h"

@protocol SearchHeadViewDelegate;

@interface SearchHeadView : UIViewExtention
{
    UIView          *contentView;
    
    UIView          *titleBG;
    UILabel*        titleLabel;
    
    UIButton*       btn0;
    UIButton*       btn1;
    UIButton*       btn2;
    UIButton*       btn3;
    UIButton*       btn4;
    UIButton*       btn5;
    
    
    id<SearchHeadViewDelegate>      delegate;
 
    NSDictionary*                   infoDict;
}
@property(nonatomic,strong)NSDictionary *infoDict;

-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializeFields;

@end

@protocol SearchHeadViewDelegate <NSObject>

@optional
-(void)onSearchHeadButtonClick:(NSString*)searchKey;


@end