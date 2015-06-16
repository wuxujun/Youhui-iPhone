//
//  ForgotPwdViewController.m
//  IWeigh
//
//  Created by xujunwu on 15/1/7.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "ForgotPwdViewController.h"
#import "HKeyboardTableView.h"
#import <SMS_SDK/SMS_SDK.h>
#import "UIButton+Category.h"
#import "UIView+LoadingView.h"
#import "StringUtils.h"
#import "UIViewController+NavigationBarButton.h"
#import "SetPwdViewController.h"

@interface ForgotPwdViewController ()<UITextFieldDelegate>

@end

@implementation ForgotPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackBarButton];
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
    [lab setText:@"找回密码"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 
    [self addRightButtonWithTitle:@"下一步" withSel:@selector(pwdRequest)];

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
    if(self.userField!=nil){
        [self.userField becomeFirstResponder];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


-(void)pwdRequest
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSString *codeStr = [self.codeField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    if (codeStr.length == 0) {
        errorMeg = @"请输入验证码。";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (codeStr.length!=4) {
        errorMeg=@"验证码长度为6位";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    __weak ForgotPwdViewController *myself=self;
    [myself.view showHUDLoadingView:YES];
    
    [SMS_SDK  commitVerifyCode:codeStr result:^(enum SMS_ResponseState state) {
        if (state==SMS_ResponseStateFail) {
            [self alertRequestResult:@"验证码输入错误." isPop:NO];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            SetPwdViewController* dController=[[SetPwdViewController alloc]init];
            dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:usernameStr,@"mobile", nil];
            [self.navigationController pushViewController:dController animated:YES];
        }
        [myself.view showHUDLoadingView:NO];
    }];
}

-(void)codeRequest
{
    NSString *usernameStr = [self.userField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *errorMeg;
    if (usernameStr.length == 0) {
        errorMeg = @"请输入手号码。";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (![StringUtils checkTelNumber:usernameStr]) {
        errorMeg=@"手机号格式错误";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    __weak ForgotPwdViewController *myself=self;
    [myself.view showHUDLoadingView:YES];
    
    [SMS_SDK getVerificationCodeBySMSWithPhone:usernameStr zone:@"86" result:^(SMS_SDKError *error) {
        DLog(@"%@",error);
        [self.codeButton setEnabled:NO];
        [self.codeButton setTitle:@"已发送" forState:UIControlStateNormal];
        [myself.view showHUDLoadingView:NO];
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

#define USER_FIELD  100
#define CODE_FIELD  200
#define AREACODE_FIELD 300

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
            [uLabel setText:@"手机号"];
            [uLabel setTextColor:[UIColor whiteColor]];
            [uLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [cell addSubview:uLabel];
            
            UITextField* areaField=[[UITextField alloc] initWithFrame:CGRectMake(80, (58-36)/2, 59, 36)];
            [areaField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [areaField setTag:AREACODE_FIELD];
            [areaField setText:@"+86"];
            [areaField setEnabled:NO];
            [areaField setTextColor:TAB_BACKGROUND_COLOR];
            [areaField setBorderStyle:UITextBorderStyleNone];
            [areaField setFont:[UIFont systemFontOfSize:16.0f]];
            [areaField setReturnKeyType:UIReturnKeyNext];
            [areaField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            [cell addSubview:areaField];
            
            
            self.userField=[[UITextField alloc] initWithFrame:CGRectMake(140, (58-36)/2, 160, 36)];
            [self.userField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [self.userField setTag:USER_FIELD];
            [self.userField setTextColor:TAB_BACKGROUND_COLOR];
            [self.userField setPlaceholder:@"请输入手机号"];
            [self.userField setBorderStyle:UITextBorderStyleNone];
            [self.userField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.userField setReturnKeyType:UIReturnKeyNext];
            [self.userField setKeyboardType:UIKeyboardTypePhonePad];
            
            [self.userField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.userField.frame;
            frame.size.width=10;
            [leftView setFrame:frame];
            [self.userField setDelegate:self];
            self.userField.leftViewMode=UITextFieldViewModeAlways;
            self.userField.leftView=leftView;
        
            [cell addSubview:self.userField];
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
            [uLabel setText:@"验证码"];
            [uLabel setTextColor:[UIColor whiteColor]];
            [uLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
            [cell addSubview:uLabel];
            
            self.codeField=[[UITextField alloc] initWithFrame:CGRectMake(80, (58-36)/2, 100, 36)];
            [self.codeField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [self.codeField setTag:CODE_FIELD];
            [self.codeField setTextColor:TAB_BACKGROUND_COLOR];
            [self.codeField setBorderStyle:UITextBorderStyleNone];
            [self.codeField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.codeField setReturnKeyType:UIReturnKeyGo];
            [self.codeField setKeyboardType:UIKeyboardTypeNumberPad];
            [self.codeField setDelegate:self];
            [self.codeField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            [cell addSubview:self.codeField];
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.codeField.frame;
            frame.size.width=10;
            [leftView setFrame:frame];
            self.codeField.leftViewMode=UITextFieldViewModeAlways;
            self.codeField.leftView=leftView;
            
            
            self.codeButton=[UIButton buttonWithType:UIButtonTypeCustom];
            [self.codeButton setFrame:CGRectMake(200, (58-36)/2, 100, 36)];
            [self.codeButton setTitle:@"点击获取" forState:UIControlStateNormal];
            [self.codeButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            [self.codeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.codeButton setBackgroundColor:[UIColor grayColor]];
            [self.codeButton addTarget:self action:@selector(codeRequest) forControlEvents:UIControlEventTouchUpInside];
            [self.codeButton  primaryStyle];
            [cell addSubview:self.codeButton];
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
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int tag=[textField tag];
    
    if (tag==USER_FIELD&&[textField returnKeyType]==UIReturnKeyNext) {
        [self.codeField becomeFirstResponder];
        [self codeRequest];
    }else if(tag==CODE_FIELD&&[textField returnKeyType]==UIReturnKeyGo){
        DLog(@"password forgot ...");
        [self pwdRequest];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField tag]==AREACODE_FIELD) {
        [self.view endEditing:YES];
    }
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
