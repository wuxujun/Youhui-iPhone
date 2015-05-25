//
//  RegViewController.h
//  Youhui
//
//  Created by xujunwu on 15/3/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface RegViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITextField*         userField;
@property(nonatomic,strong)UITextField*         passwdField;
@property(nonatomic,strong)UIButton*            regButton;
@property(nonatomic,assign)int                  nextType;


@end
