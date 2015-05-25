//
//  LoginViewController.h
//  Youhui
//
//  Created by xujunwu on 15/3/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void (^CompletionBlock)(void);

@interface LoginViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>


@property(nonatomic,strong)UITextField*         userField;
@property(nonatomic,strong)UITextField*         passField;
@property(nonatomic,strong)UIButton*            forgotButton;
@property(nonatomic,strong)UIButton*            loginButton;

@property(nonatomic,strong)CompletionBlock      completionBlock;


@end
