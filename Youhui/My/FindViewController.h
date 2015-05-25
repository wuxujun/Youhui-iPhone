//
//  FindViewController.h
//  Youhui
//
//  Created by xujunwu on 15/4/21.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BaseViewController.h"

@interface FindViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property(nonatomic,strong)UINavigationBar      *navBar;

@property(nonatomic,strong)UITextField*         mallField;
@property(nonatomic,strong)UITextField*         brandField;
@property(nonatomic,strong)UITextField*         tagField;
@property(nonatomic,strong)UITextField*         timeField;
@property(nonatomic,strong)UITextField*         picField;
@property(nonatomic,strong)UITextView*          contentField;
@property(nonatomic,strong)UIButton*            sendButton;


@end
