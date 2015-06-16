//
//  LoginViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "LoginViewController.h"
#import "HKeyboardTableView.h"
#import "RegViewController.h"
#import "UIButton+Category.h"
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"
#import "StringUtils.h"
#import "ForgotPwdViewController.h"
#import "UIViewController+NavigationBarButton.h"

@interface LoginViewController ()<UITextFieldDelegate>

@end

@implementation LoginViewController

-(id)init
{
    self=[super init];
    if (self) {
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:@"用户登录"];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addBackBarButton];
    
    UILabel* rg=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 26)];
    [rg setText:@"注册"];
    [rg setTextAlignment:NSTextAlignmentRight];
    [rg setTextColor:[UIColor whiteColor]];
    UIButton *rightBtn=[[UIButton alloc]init];
    [rightBtn setFrame:CGRectMake(0, 0,50, 30)];
    [rightBtn addSubview:rg];
    [rightBtn addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    if (mTableView==nil) {
        mTableView=[[HKeyboardTableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mTableView];
    }
}

-(IBAction)reg:(id)sender
{
    RegViewController* dController=[[RegViewController alloc]init];
    dController.nextType=0;
    [self.navigationController pushViewController:dController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordStr = [self.passField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *errorMeg;
    if (usernameStr.length == 0) {
        errorMeg = @"请输入用户帐号。";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (![StringUtils checkTelNumber:usernameStr]) {
        errorMeg=@"手机号格式错误";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (passwordStr.length==0) {
        errorMeg=@"登录密码不能为空.";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (passwordStr.length<6) {
        errorMeg=@"密码必须6位以上.";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    __weak LoginViewController *myself=self;
    [myself.view showHUDLoadingView:YES];
    [[HCurrentUserContext sharedInstance] loginWithUserName:usernameStr password:passwordStr success:^(MKNetworkOperation *completedOperation, id result) {
        [self alertRequestResult:@"登录成功" isPop:YES];
    } error:^(NSError *error) {
        ELog(error);
        [myself alertRequestResult:error.domain isPop:NO];
        [myself.view showHUDLoadingView:NO];
    }];
    
}

-(IBAction)passRequest:(id)sender
{
    ForgotPwdViewController* dController=[[ForgotPwdViewController alloc]init];
    [self.navigationController pushViewController:dController animated:YES];
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==3) {
        return 44;
    }
    return 60.0;
}

#define USER_FIELD  100
#define PASSWORD_FIELD 200

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    CGRect bounds=self.view.frame;
    switch (indexPath.row) {
        case 0:
        {
            
            self.userField=[[UITextField alloc] initWithFrame:CGRectMake(20, (58-36)/2, bounds.size.width-40, 36)];
            [self.userField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [self.userField setTextColor:TAB_BACKGROUND_COLOR];
            [self.userField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.userField setTag:USER_FIELD];
            [self.userField setPlaceholder:@"请输入手机号"];
            [self.userField setBorderStyle:UITextBorderStyleNone];
            [self.userField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.userField setReturnKeyType:UIReturnKeyNext];
            [self.userField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.userField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.userField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            
//            [self.userField setText:@"13958197001"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.userField.frame;
            frame.size.width=36;
            [leftView setFrame:frame];
            UIImageView *tel=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_input_tel"]];
            [tel setFrame:CGRectMake(9, 9, 18, 18)];
            [leftView addSubview:tel];
            self.userField.leftViewMode=UITextFieldViewModeAlways;
            self.userField.leftView=leftView;
            [self.userField setDelegate:self];
            [cell addSubview:self.userField];
            
            break;
        }
        case 1:
        {
          
            self.passField=[[UITextField alloc] initWithFrame:CGRectMake(20, (58-36)/2, bounds.size.width-40, 36)];
            [self.passField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [self.passField setTextColor:TAB_BACKGROUND_COLOR];
            [self.passField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.passField setTag:PASSWORD_FIELD];
            [self.passField setPlaceholder:@"请输入密码"];
            [self.passField setBorderStyle:UITextBorderStyleNone];
            [self.passField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.passField setSecureTextEntry:YES];
            [self.passField setReturnKeyType:UIReturnKeyGo];
            [self.userField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.passField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.passField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            
//            [self.passField setText:@"123456"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.userField.frame;
            frame.size.width=36;
            [leftView setFrame:frame];
            UIImageView *tel=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_input_pwd"]];
            [tel setFrame:CGRectMake(9, 9, 18, 18)];
            [leftView addSubview:tel];
            self.passField.leftViewMode=UITextFieldViewModeAlways;
            self.passField.leftView=leftView;
            
            [self.passField setDelegate:self];
            [cell addSubview:self.passField];
            
            break;
        }
        case 2:
        {
            self.loginButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.loginButton setFont:[UIFont systemFontOfSize:16.0f]];
            [self.loginButton setFrame:CGRectMake(20, 10,bounds.size.width-40, 40)];
            [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
            [self.loginButton setTintColor:[UIColor whiteColor]];
            [self.loginButton primaryStyle];
            [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:self.loginButton];
            
        }
            break;
        default:
        {
            self.forgotButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.forgotButton setFont:[UIFont systemFontOfSize:16.0f]];
            [self.forgotButton setFrame:CGRectMake(bounds.size.width-120, 5, 100, 34)];
            [self.forgotButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
            [self.forgotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.forgotButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [self.forgotButton setBackgroundColor:[UIColor clearColor]];
            [self.forgotButton addTarget:self action:@selector(passRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell addSubview:self.forgotButton];

        }
            break;
    }
   
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"%@   %d",textField.text,[textField returnKeyType]);
    
    int tag=[textField tag];
    if (tag==USER_FIELD&&[textField returnKeyType]==UIReturnKeyNext) {
        if (self.passField) {
            [self.passField becomeFirstResponder];
        }
    }else if(tag==PASSWORD_FIELD&&[textField returnKeyType]==UIReturnKeyGo){
        DLog(@"login.....");
        [self login];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}


@end
