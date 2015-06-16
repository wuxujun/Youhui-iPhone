//
//  SetPwdViewController.m
//  Youhui
//
//  Created by xujunwu on 15/5/27.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "SetPwdViewController.h"
#import "HKeyboardTableView.h"
#import <SMS_SDK/SMS_SDK.h>
#import "UIButton+Category.h"
#import "HCurrentUserContext.h"
#import "StringUtils.h"
#import "UIView+LoadingView.h"
#import "UIViewController+NavigationBarButton.h"

@interface SetPwdViewController ()<UITextFieldDelegate>

@end


@implementation SetPwdViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackBarButton];
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
    [lab setText:@"密码设置"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self addRightButtonWithTitle:@"提交" withSel:@selector(pwdRequest)];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (mTableView==nil) {
        mTableView=[[HKeyboardTableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        mTableView.backgroundColor=RGBCOLOR(30, 33, 38);
        mTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        mTableView.delegate = (id<UITableViewDelegate>)self;
        mTableView.dataSource = (id<UITableViewDataSource>)self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mTableView];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.pwdField!=nil){
        [self.pwdField becomeFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(void)pwdRequest
{
    NSString *pwdStr = [self.pwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *pwd2Str = [self.pwd2Field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    if (pwdStr.length == 0) {
        errorMeg = @"请输入密码。";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (pwd2Str.length==0) {
        errorMeg=@"请输入确认密码";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    
    if (![pwdStr isEqual:pwd2Str]) {
        errorMeg=@"两次输入密码不一致.";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    __weak SetPwdViewController *myself=self;
    [myself.view showHUDLoadingView:YES];
    
    [[HCurrentUserContext sharedInstance] setPassworkWithUsername:[self.infoDict objectForKey:@"mobile"] password:pwdStr success:^(BOOL success) {
        [self alertRequestResult:@"密码设置成功" isPop:YES];
        [myself.view showHUDLoadingView:NO];
    } error:^(NSError *error) {
         [myself.view showHUDLoadingView:NO];
        [self alertRequestResult:@"密码设置失败" isPop:NO];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#define PWD_FIELD  100
#define PWD2_FIELD  200

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
            UILabel* uLabel=[[UILabel alloc]init];
            [uLabel setFrame:CGRectMake(20, (58-26)/2, 80, 26)];
            [uLabel setText:@"新密码"];
            [uLabel setTextColor:[UIColor whiteColor]];
            [uLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [cell addSubview:uLabel];
            
            self.pwdField=[[UITextField alloc] initWithFrame:CGRectMake(100, (58-36)/2, bounds.size.width-120, 36)];
            [self.pwdField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [self.pwdField setTag:PWD_FIELD];
            [self.pwdField setTextColor:TAB_BACKGROUND_COLOR];
            [self.pwdField setPlaceholder:@"请输入新密码"];
            [self.pwdField setBorderStyle:UITextBorderStyleNone];
            [self.pwdField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.pwdField setReturnKeyType:UIReturnKeyNext];
            [self.pwdField setKeyboardType:UIKeyboardTypePhonePad];
            [self.pwdField setSecureTextEntry:YES];
            
            [self.pwdField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.pwdField.frame;
            frame.size.width=10;
            [leftView setFrame:frame];
            [self.pwdField setDelegate:self];
            self.pwdField.leftViewMode=UITextFieldViewModeAlways;
            self.pwdField.leftView=leftView;
            
            [cell addSubview:self.pwdField];
            UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 59, bounds.size.width, 1)];
            [img setImage:[UIImage imageNamed:@"contentview_topline"]];
            [cell addSubview:img];
            [cell sendSubviewToBack:img];
        }
            break;
        case 1:
        {
            UILabel* uLabel=[[UILabel alloc]init];
            [uLabel setFrame:CGRectMake(20, (58-26)/2, 80, 26)];
            [uLabel setText:@"确认密码"];
            [uLabel setTextColor:[UIColor whiteColor]];
            [uLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [cell addSubview:uLabel];
            
            self.pwd2Field=[[UITextField alloc] initWithFrame:CGRectMake(100, (58-36)/2, bounds.size.width-120, 36)];
            [self.pwd2Field setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [self.pwd2Field setTag:PWD2_FIELD];
            [self.pwd2Field setTextColor:TAB_BACKGROUND_COLOR];
            [self.pwd2Field setPlaceholder:@"请输入确认密码"];
            [self.pwd2Field setBorderStyle:UITextBorderStyleNone];
            [self.pwd2Field setFont:[UIFont systemFontOfSize:16.0f]];
            [self.pwd2Field setReturnKeyType:UIReturnKeyGo];
            [self.pwd2Field setKeyboardType:UIKeyboardTypeNumberPad];
            [self.pwd2Field setSecureTextEntry:YES];
            [self.pwd2Field setDelegate:self];
            [self.pwd2Field setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            [cell addSubview:self.pwd2Field];
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.pwd2Field.frame;
            frame.size.width=10;
            [leftView setFrame:frame];
            self.pwd2Field.leftViewMode=UITextFieldViewModeAlways;
            self.pwd2Field.leftView=leftView;
        
            UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 59, bounds.size.width, 1)];
            [img setImage:[UIImage imageNamed:@"contentview_topline"]];
            [cell addSubview:img];
            [cell sendSubviewToBack:img];
        }
            break;
        case 4:
        {
            
        }
            break;
        default:
            break;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}
#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag=[textField tag];
    
    if (tag==PWD_FIELD&&[textField returnKeyType]==UIReturnKeyNext) {
        [self.pwd2Field becomeFirstResponder];
    }else if(tag==PWD2_FIELD&&[textField returnKeyType]==UIReturnKeyGo){
        DLog(@"password forgot ...");
        [self pwdRequest];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
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
