//
//  SetPwdViewController.h
//  Youhui
//
//  Created by xujunwu on 15/5/27.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SetPwdViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITextField*         pwdField;
@property(nonatomic,strong)UITextField*         pwd2Field;

@end
