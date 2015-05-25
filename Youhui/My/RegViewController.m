//
//  RegViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "RegViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UIButton+Category.h"
#import "HKeyboardTableView.h"
#import "StringUtils.h"
#import <SMS_SDK/SMS_SDK.h>
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"

@interface RegViewController ()<UITextFieldDelegate>
{
    NSString            *mobile;
}
@property (nonatomic,strong)UILabel     *navTitle;

@end

@implementation RegViewController
-(id)init
{
    self=[super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addBackBarButton];
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    if (mTableView==nil) {
        mTableView=[[HKeyboardTableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mTableView];
    }
    self.navTitle=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
    if (self.nextType==0) {
        [self.navTitle setText:@"用户注册"];
    }else if(self.nextType==1){
        [self.navTitle setText:@"填写验证码"];
    }else {
        
        [self.navTitle setText:@"设置登录密码和昵称"];
    }
    [self.navTitle setTextAlignment:NSTextAlignmentCenter];
    [self.navTitle setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=self.navTitle;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.nextType==2&&self.infoDict) {
        mobile=[self.infoDict objectForKey:@"mobile"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refrshData
{
    if (self.nextType==0) {
        [self.navTitle setText:@"用户注册"];
    }else if(self.nextType==1){
        [self.navTitle setText:@"填写验证码"];
    }else {
        
        [self.navTitle setText:@"设置登录密码和昵称"];
    }
    [mTableView reloadData];
}

-(void)codeRequest
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
    [SMS_SDK getVerificationCodeBySMSWithPhone:usernameStr zone:@"86" result:^(SMS_SDKError *error) {
        if (error) {
            [self alertRequestResult:error.errorDescription isPop:NO];
        }else{
            mobile=usernameStr;
            self.nextType=1;
            [self refrshData];
//            RegViewController* dController=[[RegViewController alloc]init];
//            dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:usernameStr,@"mobile", nil];
//            dController.nextType=1;
//            [self.navigationController pushViewController:dController animated:YES];
        }
    }];

    
}

-(void)nextRequest
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    if (usernameStr.length == 0) {
        errorMeg = @"请输入验证码。";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    [SMS_SDK commitVerifyCode:usernameStr result:^(enum SMS_ResponseState state) {
        if (state==SMS_ResponseStateSuccess) {
            self.nextType=2;
            [self refrshData];
//            RegViewController* dController=[[RegViewController alloc]init];
//            dController.nextType=2;
//            dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:[self.infoDict objectForKey:@"mobile"],@"mobile", nil];
//            [self.navigationController pushViewController:dController animated:YES];
        }else{
            [self alertRequestResult:@"验证码错误" isPop:NO];
        }
    }];
}

-(void)regRequest
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordStr = [self.passwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *errorMeg;
    if (usernameStr.length == 0) {
        errorMeg = @"请设置您的昵称!";
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
    
    __weak RegViewController *myself=self;
    [myself.view showHUDLoadingView:YES];
    [[HCurrentUserContext sharedInstance] registerNewWithMobile:mobile username:usernameStr password:passwordStr success:^(BOOL success) {
        if (success) {
            [myself autoLogin:mobile password:passwordStr];
        }
    } error:^(NSError *error) {
        ELog(error);
        [myself alertRequestResult:error.domain isPop:NO];
        [myself.view showHUDLoadingView:NO];
    }];

}

-(void)autoLogin:(NSString*)mobileStr password:(NSString*)password
{
    __weak RegViewController *myself=self;
    [myself.view showHUDLoadingView:YES];
    [[HCurrentUserContext sharedInstance] loginWithUserName:mobileStr password:password success:^(MKNetworkOperation *completedOperation, id result) {
        [self alertRequestResult:@"登录成功" isPop:YES];
    } error:^(NSError *error) {
        ELog(error);
        [myself alertRequestResult:error.domain isPop:NO];
        [myself.view showHUDLoadingView:NO];
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.nextType) {
        case 1:
            return 4;
        default:
            return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
#define USER_FIELD  100
#define PASS_FIELD  101
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    CGRect bounds=self.view.frame;
    if (self.nextType==0) {
        switch (indexPath.row) {
            case 0:
            {
                self.userField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-36)/2, bounds.size.width-40, 36)];
                [self.userField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.userField setTextColor:TAB_BACKGROUND_COLOR];
                [self.userField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.userField setTag:USER_FIELD];
                [self.userField setPlaceholder:@"请输入手机号"];
                [self.userField setBorderStyle:UITextBorderStyleNone];
                [self.userField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.userField setReturnKeyType:UIReturnKeyGo];
                [self.userField setKeyboardType:UIKeyboardTypePhonePad];
                [self.userField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.userField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.userField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
                UIView *leftView=[[UIView alloc] init];
                
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
               
            }
                break;
            case 1:
            {
                self.regButton=[UIButton buttonWithType:UIButtonTypeCustom];
                [self.regButton setFrame:CGRectMake(20, (58-36)/2, bounds.size.width-40, 36)];
                [self.regButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                [self.regButton  primaryStyle];
            
                [self.regButton addTarget:self action:@selector(codeRequest) forControlEvents:UIControlEventTouchUpInside];
            
                [cell addSubview:self.regButton];
            }
                break;
            default:
            {
                UISwitch* sw=[[UISwitch alloc]initWithFrame:CGRectMake(20, 15, 60, 30)];
                [sw setOn:YES];
                [sw addTarget:self action:@selector(swSend:) forControlEvents:UIControlEventEditingChanged];
                [cell addSubview:sw];
                UILabel* title=[[UILabel alloc]initWithFrame:CGRectMake(80, (60-50)/2, bounds.size.width-100, 50)];
                [title setText:@"我已看过并同意商场密探《用户使用协议》"];
                [title setNumberOfLines:0];
                [title setLineBreakMode:NSLineBreakByWordWrapping];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [title setTextColor:[UIColor whiteColor]];
                [cell addSubview:title];
            }
                break;
        }
    }else if (self.nextType==1){
        switch (indexPath.row) {
            case 0:
            {
                UILabel* title=[[UILabel alloc]initWithFrame:CGRectMake(40, (60-26)/2, bounds.size.width-50, 26)];
                NSString* t=[NSString stringWithFormat:@"已发送验证码到%@,请稍后",mobile];
                [title setText:t];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [title setTextColor:[UIColor whiteColor]];
                [cell addSubview:title];
            }
                break;
            case 1:
            {
                self.userField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-36)/2, bounds.size.width-40, 36)];
                [self.userField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.userField setTextColor:TAB_BACKGROUND_COLOR];
                [self.userField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.userField setTag:USER_FIELD];
                [self.userField setPlaceholder:@"请输入验证码"];
                [self.userField setBorderStyle:UITextBorderStyleNone];
                [self.userField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.userField setReturnKeyType:UIReturnKeyGo];
                [self.userField setKeyboardType:UIKeyboardTypePhonePad];
                [self.userField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.userField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.userField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
                
                UIView *leftView=[[UIView alloc]init];
                CGRect frame=self.userField.frame;
                frame.size.width=36;
                [leftView setFrame:frame];
                UIImageView *tel=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_input_pwd"]];
                [tel setFrame:CGRectMake(9, 9, 18, 18)];
                [leftView addSubview:tel];
                self.userField.leftViewMode=UITextFieldViewModeAlways;
                self.userField.leftView=leftView;
                [self.userField setDelegate:self];
                [cell addSubview:self.userField];
               
                
            }
                break;
            case 2:{
                self.regButton=[UIButton buttonWithType:UIButtonTypeCustom];
                [self.regButton setFrame:CGRectMake(20, (58-36)/2, bounds.size.width-40, 36)];
                [self.regButton setTitle:@"下一步" forState:UIControlStateNormal];
                [self.regButton  primaryStyle];
                
                [self.regButton addTarget:self action:@selector(nextRequest) forControlEvents:UIControlEventTouchUpInside];
                
                [cell addSubview:self.regButton];
            }
                break;
            default:
            {
                UISwitch* sw=[[UISwitch alloc]initWithFrame:CGRectMake(20, 15, 60, 30)];
                [sw setOn:YES];
                [sw addTarget:self action:@selector(swSend:) forControlEvents:UIControlEventEditingChanged];
                [cell addSubview:sw];
            
                UILabel* title=[[UILabel alloc]initWithFrame:CGRectMake(80, (60-26)/2, bounds.size.width-50, 26)];
                [title setText:@"我已看过并同意商场密探《用户使用协议》"];
                [title setFont:[UIFont systemFontOfSize:14.0f]];
                [title setTextColor:[UIColor whiteColor]];
                [cell addSubview:title];
            }
                break;
        }
    }else if(self.nextType==2){
        switch (indexPath.row) {
            case 0:
            {
                self.userField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-36)/2, bounds.size.width-40, 36)];
                [self.userField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.userField setTextColor:TAB_BACKGROUND_COLOR];
                [self.userField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.userField setTag:USER_FIELD];
                [self.userField setPlaceholder:@"请设置您的昵称"];
                [self.userField setBorderStyle:UITextBorderStyleNone];
                [self.userField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.userField setReturnKeyType:UIReturnKeyGo];
                [self.userField setKeyboardType:UIKeyboardTypeDefault];
                [self.userField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.userField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.userField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
                
                UIView *leftView=[[UIView alloc]init];
                CGRect frame=self.userField.frame;
                frame.size.width=36;
                [leftView setFrame:frame];
                UIImageView *tel=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_input_user"]];
                [tel setFrame:CGRectMake(9, 9, 18, 18)];
                [leftView addSubview:tel];
                self.userField.leftViewMode=UITextFieldViewModeAlways;
                self.userField.leftView=leftView;
                [self.userField setDelegate:self];
                [cell addSubview:self.userField];
              
            }
                break;
            case 1:{
                self.passwdField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-36)/2, bounds.size.width-40, 36)];
                [self.passwdField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.passwdField setTextColor:TAB_BACKGROUND_COLOR];
                [self.passwdField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.passwdField setTag:PASS_FIELD];
                [self.passwdField setPlaceholder:@"请设置您的登录密码"];
                [self.passwdField setBorderStyle:UITextBorderStyleNone];
                [self.passwdField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.passwdField setReturnKeyType:UIReturnKeyDone];
                [self.passwdField setSecureTextEntry:YES];
                [self.passwdField setKeyboardType:UIKeyboardTypePhonePad];
                [self.passwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.passwdField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.passwdField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
                
                UIView *leftView=[[UIView alloc]init];
                CGRect frame=self.passwdField.frame;
                frame.size.width=36;
                [leftView setFrame:frame];
                UIImageView *tel=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_input_pwd"]];
                [tel setFrame:CGRectMake(9, 9, 18, 18)];
                [leftView addSubview:tel];
                self.passwdField.leftViewMode=UITextFieldViewModeAlways;
                self.passwdField.leftView=leftView;
                [self.passwdField setDelegate:self];
                [cell addSubview:self.passwdField];
               
            }
                break;
            default:
            {
                self.regButton=[UIButton buttonWithType:UIButtonTypeCustom];
                [self.regButton setFrame:CGRectMake(20, (58-36)/2, bounds.size.width-40, 36)];
                [self.regButton setTitle:@"注册并登录" forState:UIControlStateNormal];
                [self.regButton  primaryStyle];
                
                [self.regButton addTarget:self action:@selector(regRequest) forControlEvents:UIControlEventTouchUpInside];
                
                [cell addSubview:self.regButton];
            }
                break;
        }
    }
    
    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 59, bounds.size.width, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(IBAction)swSend:(id)sender
{
    UISwitch* sw=(UISwitch*)sender;
    if (sw.on) {
        [self.regButton setEnabled:NO];
    }else{
        [self.regButton setEnabled:YES];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.nextType==0) {
        if(textField.tag==USER_FIELD&&[textField returnKeyType]==UIReturnKeyGo){
            DLog(@"register ...");
            [self codeRequest];
        }
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
