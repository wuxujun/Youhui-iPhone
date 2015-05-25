//
//  MyHeadView.h
//  Youhui
//
//  Created by xujunwu on 15/3/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "UIViewExtention.h"

@protocol MyHeadViewDelegate;

@interface MyHeadView : UIViewExtention
{
    UIImageView         * bgView;
    UIImageView         *avatarView;
    
    UIButton            *loginBtn;
    UIButton            *registerBtn;
    
    UIButton            *cellButton;
    UILabel             *userLabel;
    UILabel             *cityLabel;
    
    id<MyHeadViewDelegate>      delegate;
    
}
-(id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;

-(void)initializedFields;
-(void)refresh;
-(void)logout;

@end


@protocol MyHeadViewDelegate <NSObject>

-(void)onMyHeadViewLoginClicked;
-(void)onMyHeadViewRegisterClicked;
-(void)onMyHeadViewAvatarClicked;
-(void)onMyHeadViewClicked;

@end