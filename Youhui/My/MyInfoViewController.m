//
//  MyInfoViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/25.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MyInfoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BrandViewController.h"
#import "UIButton+Category.h"
#import "UIViewController+NavigationBarButton.h"
#import "CollectEntity.h"
#import "HKeyboardTableView.h"
#import "UIImageView+AFNetworking.h"
#import "AppConfig.h"
#import "HCurrentUserContext.h"
#import "UserDefaultHelper.h"

@interface MyInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate>
{
    NSString*       nickStr;
    NSString*       cityStr;
    
    NSString*       fileName;
    NSString*       filePath;
}
@end

@implementation MyInfoViewController

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
        mTableView=[[HKeyboardTableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mTableView];
    }
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 25, 200, 34)];
    [lab setText:@"我的信息"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    
    if ([[HCurrentUserContext sharedInstance] uid]) {
        nickStr=[[HCurrentUserContext sharedInstance] username];
    }
    
    if (self.avatarBtn==nil) {
        self.avatarBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 140)];
        [self.avatarBtn addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.avatarImg==nil) {
        self.avatarImg=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-120)/2, 10, 120, 120)];
        [self.avatarImg setImage:[UIImage imageNamed:@"ic_normal"]];
        self.avatarImg.layer.cornerRadius=60;
        self.avatarImg.layer.masksToBounds=YES;
    }
}

-(IBAction)openCamera:(id)sender
{
    [self showImagePicker];
}

-(IBAction)save:(id)sender
{
    NSString *errorMeg;
    if (nickStr.length == 0) {
        errorMeg = @"请输入昵称";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (cityStr.length == 0) {
        errorMeg = @"请输入城市";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    [UserDefaultHelper setObject:nickStr forKey:@"user_nick"];
    [UserDefaultHelper setObject:cityStr forKey:@"user_city_name"];
    if (filePath.length>0) {
        [UserDefaultHelper setObject:filePath forKey:@"user_avatar_url"];
    }
    
    [self alertRequestResult:@"保存成功." isPop:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (indexPath.row==0) {
        return 140;
    }
    return 58.0;
    
}
#define NICK_FIELD  100
#define CITY_FIELD  101

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    CGRect bounds=self.view.frame;
    if (indexPath.section==0) {
        switch (indexPath.row) {
            case 0:
            {
                [cell addSubview:self.avatarImg];
                [cell addSubview:self.avatarBtn];
            }
                break;
            case 2:
            {
                self.cityField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-46)/2, bounds.size.width-40, 46)];
                [self.cityField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.cityField setTextColor:TAB_BACKGROUND_COLOR];
                [self.cityField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.cityField setTag:CITY_FIELD];
                [self.cityField setPlaceholder:@"请输入城市"];
                [self.cityField setBorderStyle:UITextBorderStyleNone];
                [self.cityField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.cityField setReturnKeyType:UIReturnKeyDone];
                [self.cityField setKeyboardType:UIKeyboardTypeDefault];
                [self.cityField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.cityField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.cityField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
                if (cityStr) {
                    [self.cityField setText:cityStr];
                }
                UIView *leftView=[[UIView alloc] init];
                
                CGRect frame=self.cityField.frame;
                frame.size.width=60;
                [leftView setFrame:frame];
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, (46-26)/2, 60, 26)];
                [lab setText:@"城市"];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setTextColor:[UIColor whiteColor]];
                [leftView addSubview:lab];
                self.cityField.leftViewMode=UITextFieldViewModeAlways;
                self.cityField.leftView=leftView;
                [self.cityField setDelegate:self];
                [cell addSubview:self.cityField];
            }
                break;
            case 3:{
                self.sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
                [self.sendButton setFrame:CGRectMake(20, (58-36)/2, bounds.size.width-40, 36)];
                [self.sendButton setTitle:@"保存" forState:UIControlStateNormal];
                [self.sendButton  primaryStyle];
                
                [self.sendButton addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell addSubview:self.sendButton];
            }
                break;
            default:
            {
                self.nickField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-46)/2, bounds.size.width-40, 46)];
                [self.nickField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.nickField setTextColor:TAB_BACKGROUND_COLOR];
                [self.nickField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.nickField setTag:NICK_FIELD];
                [self.nickField setPlaceholder:@"请输入昵称"];
                [self.nickField setBorderStyle:UITextBorderStyleNone];
                [self.nickField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.nickField setReturnKeyType:UIReturnKeyNext];
                [self.nickField setKeyboardType:UIKeyboardTypeDefault];
                [self.nickField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.nickField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.nickField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
                if (nickStr) {
                    [self.nickField setText:nickStr];
                }
                [self.nickField becomeFirstResponder];
                
                UIView *leftView=[[UIView alloc] init];
                
                CGRect frame=self.nickField.frame;
                frame.size.width=60;
                [leftView setFrame:frame];
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, (46-26)/2, 60, 26)];
                [lab setText:@"昵称"];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setTextColor:[UIColor whiteColor]];
                [leftView addSubview:lab];
                self.nickField.leftViewMode=UITextFieldViewModeAlways;
                self.nickField.leftView=leftView;
                [self.nickField setDelegate:self];
                [cell addSubview:self.nickField];
                
            }
                break;
        }
    }

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)showImagePicker
{
    BOOL hasCamera=[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera) {
        [self alertRequestResult:@"对不起,拍照功能不支持" isPop:NO];
    }
    UIImagePickerController* dController=[[UIImagePickerController alloc]init];
    dController.delegate=self;
    dController.sourceType=UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:dController animated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *curTime=[formatter stringFromDate:[NSDate date] ];
    if ([mediaType isEqualToString:@"public.image"]) {
        fileName=[NSString stringWithFormat:@"%@.jpg",curTime];
        filePath=[NSString stringWithFormat:@"%@/%@",[[AppConfig getInstance] getDownPath],fileName];
        
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:UIImageJPEGRepresentation(image, 0.8) attributes:nil];
        if (self.avatarImg) {
            [self.avatarImg setImage:[UIImage imageNamed:filePath]];
        }
    }
    
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag==NICK_FIELD) {
        nickStr=[NSString stringWithFormat:@"%@",textField.text];
    }
    else if (textField.tag==CITY_FIELD) {
        cityStr=[NSString stringWithFormat:@"%@",textField.text];
    }
    return YES;
}
@end
