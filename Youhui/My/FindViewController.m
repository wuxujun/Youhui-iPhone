//
//  FindViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/21.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "FindViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UIButton+Category.h"
#import "StringUtils.h"
#import "AppConfig.h"
#import "HKeyboardTableView.h"

@interface FindViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate>
{
    NSString        *fileName;
    NSString        *filePath;
    
    NSString            *mallNameStr;
    NSString            *brandNameStr;
    NSString            *tagNameStr;
    NSString            *timeStr;
    NSString            *contentStr;
    
    UIAlertController       *alertController;
}

@property (nonatomic,strong)UILabel        *contentTip;
@property (nonatomic,strong)UIButton        *tagButton;
@property (nonatomic,strong)UIButton        *picButton;
@property (nonatomic,strong)UIButton        *cameraButton;
@property (nonatomic,strong)UIImageView     *picImage;

@end

@implementation FindViewController

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
    
    if (self.navBar==nil) {
        self.navBar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    }
    [self.view addSubview:self.navBar];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(0, 20, 44.0f, 44.0f);
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_back_selected"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:button];
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    
    if (mTableView==nil) {
        mTableView=[[HKeyboardTableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mTableView];
    }
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 25, 200, 34)];
    [lab setText:@"发现"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    [self.navBar addSubview:lab];
    
    
    if (self.contentTip==nil) {
        self.contentTip=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, self.view.frame.size.width-60, 58)];
        [self.contentTip setText:@"请输入描述"];
        [self.contentTip setTextColor:[UIColor grayColor]];
        
    }
    if (self.tagButton==nil) {
        self.tagButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 58)];
//        [self.tagButton setBackgroundColor:[UIColor redColor]];
        [self.tagButton addTarget:self action:@selector(hideButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.picButton==nil) {
        self.picButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 58)];
        [self.picButton addTarget:self action:@selector(hideButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.cameraButton==nil) {
        self.cameraButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, 0, 58, 58)];
        [self.cameraButton setImage:[UIImage imageNamed:@"ic_camera"] forState:UIControlStateNormal];
        [self.cameraButton addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.picImage==nil) {
        self.picImage=[[UIImageView alloc]initWithFrame:CGRectMake(200, 5, 48, 48)];
        
    }
}

-(IBAction)openCamera:(id)sender
{
    [self showImagePicker:YES];
}

-(void)openPhoto
{
    [self showImagePicker:NO];
}

-(IBAction)hideButton:(id)sender
{
    if (self.mallField) {
        [self.mallField resignFirstResponder];
    }
    if (self.brandField) {
        [self.brandField resignFirstResponder];
    }
    if (self.timeField) {
        [self.timeField resignFirstResponder];
    }
    if (self.contentField) {
        [self.contentField resignFirstResponder];
    }
    UIButton* btn=(UIButton*)sender;
    [btn setHidden:YES];
}

-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)uploadRequest
{
    NSString *errorMeg;
    if (mallNameStr.length == 0) {
        errorMeg = @"请输入商场名称";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (brandNameStr.length == 0) {
        errorMeg = @"请输入品牌名称";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (tagNameStr.length == 0) {
        errorMeg = @"请输入标签名称";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (timeStr.length == 0) {
        errorMeg = @"请选择时间";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    if (contentStr.length == 0) {
        errorMeg = @"请输入描述";
        [self alertRequestResult:errorMeg isPop:NO];
        return;
    }
    
    NSMutableDictionary* dic=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[AppConfig getInstance] getIMEI],@"imei", nil];
                              

    NSMutableDictionary* params=[[NSMutableDictionary alloc]init];
    [dic setObject:mallNameStr forKey:@"mallName"];
    [dic setObject:brandNameStr forKey:@"brandName"];
    [dic setObject:timeStr forKey:@"time"];
    [dic setObject:tagNameStr forKey:@"tagName"];
    [dic setObject:contentStr forKey:@"remark"];
    
    NSMutableDictionary *imgs=[[NSMutableDictionary alloc]init];
    if (filePath) {
        [imgs setObject:filePath forKey:@"image"];
        [params setObject:filePath forKey:@"image"];
    }
    [dic setObject:imgs forKey:@"images"];
    
    [params setObject:dic forKey:@"content"];
    DLog(@"%@",params);
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@addFind",kHttpUrl];
    
    [self.networkEngine postDatasWithURLString:requestUrl datas:params process:^(double progress) {
    } success:^(MKNetworkOperation *completedOperation, id result) {
        [self alertRequestResult:@"上传成功,稍后将由工作人员审批" isDisses:NO];
    } error:^(NSError *error) {
        [self alertRequestResult:@"上传失败" isPop:NO];
    }];

}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        default:
            return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1&&indexPath.row==3) {
        return 200;
    }
    return 58.0;
    
}
#define MALL_FIELD  100
#define BRAND_FIELD  101
#define TAG_FIELD   102
#define TIME_FIELD  103
#define PIC_FIELD   104
#define CONTENT_FIELD 105

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
                self.mallField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-46)/2, bounds.size.width-40, 46)];
                [self.mallField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.mallField setTextColor:TAB_BACKGROUND_COLOR];
                [self.mallField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.mallField setTag:MALL_FIELD];
                [self.mallField setPlaceholder:@"请输入商场"];
                [self.mallField setBorderStyle:UITextBorderStyleNone];
                [self.mallField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.mallField setReturnKeyType:UIReturnKeyNext];
                [self.mallField setKeyboardType:UIKeyboardTypeDefault];
                [self.mallField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.mallField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.mallField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
                if (mallNameStr) {
                    [self.mallField setText:mallNameStr];
                }
                UIView *leftView=[[UIView alloc] init];
                
                CGRect frame=self.mallField.frame;
                frame.size.width=60;
                [leftView setFrame:frame];
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, (46-26)/2, 60, 26)];
                [lab setText:@"商场"];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setTextColor:[UIColor whiteColor]];
                [leftView addSubview:lab];
                self.mallField.leftViewMode=UITextFieldViewModeAlways;
                self.mallField.leftView=leftView;
                [self.mallField setDelegate:self];
                [cell addSubview:self.mallField];
            }
                break;
            default:
            {
                self.brandField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-46)/2, bounds.size.width-40, 46)];
                [self.brandField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.brandField setTextColor:TAB_BACKGROUND_COLOR];
                [self.brandField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.brandField setTag:BRAND_FIELD];
                [self.brandField setPlaceholder:@"请输入品牌"];
                [self.brandField setBorderStyle:UITextBorderStyleNone];
                [self.brandField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.brandField setReturnKeyType:UIReturnKeyNext];
                [self.brandField setKeyboardType:UIKeyboardTypeDefault];
                [self.brandField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.brandField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.brandField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
                if (brandNameStr) {
                    [self.brandField setText:brandNameStr];
                }
                UIView *leftView=[[UIView alloc] init];
                
                CGRect frame=self.brandField.frame;
                frame.size.width=60;
                [leftView setFrame:frame];
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, (46-26)/2, 60, 26)];
                [lab setText:@"品牌"];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setTextColor:[UIColor whiteColor]];
                [leftView addSubview:lab];
                self.brandField.leftViewMode=UITextFieldViewModeAlways;
                self.brandField.leftView=leftView;
                [self.brandField setDelegate:self];
                [cell addSubview:self.brandField];
                
            }
                break;
        }
    }else if (indexPath.section==1){
        switch (indexPath.row) {
            case 0:
            {
                self.tagField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-46)/2, bounds.size.width-40, 46)];
                [self.tagField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.tagField setTextColor:TAB_BACKGROUND_COLOR];
                [self.tagField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.tagField setTag:TAG_FIELD];
                [self.tagField setPlaceholder:@"请选择标签"];
                [self.tagField setBorderStyle:UITextBorderStyleNone];
                [self.tagField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.tagField setReturnKeyType:UIReturnKeyDone];
                [self.tagField setKeyboardType:UIKeyboardTypeDefault];
                [self.tagField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.tagField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.tagField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
                [self.timeField setEnabled:YES];
                [self.tagField addTarget:self action:@selector(didChangeTag:) forControlEvents:UIControlEventEditingDidBegin];
                if (tagNameStr) {
                    [self.tagField setText:tagNameStr];
                }
                UIView *leftView=[[UIView alloc] init];
                
                CGRect frame=self.tagField.frame;
                frame.size.width=60;
                [leftView setFrame:frame];
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, (46-26)/2, 60, 26)];
                [lab setText:@"标签"];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setTextColor:[UIColor whiteColor]];
                [leftView addSubview:lab];
                self.tagField.leftViewMode=UITextFieldViewModeAlways;
                self.tagField.leftView=leftView;
                [self.tagField setDelegate:self];
                [cell addSubview:self.tagField];
                
                if (self.tagButton) {
                    [cell addSubview:self.tagButton];
                }

               
            }
                break;
            case 1:
            {
                self.timeField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-46)/2, bounds.size.width-40,46)];
                [self.timeField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.timeField setTextColor:TAB_BACKGROUND_COLOR];
                [self.timeField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.timeField setTag:TIME_FIELD];
                [self.timeField setPlaceholder:@"请输入时间"];
                [self.timeField setBorderStyle:UITextBorderStyleNone];
                [self.timeField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.timeField setReturnKeyType:UIReturnKeyDone];
                [self.timeField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.timeField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.timeField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
                
                if (timeStr) {
                    [self.timeField setText:timeStr];
                }
                UIView *leftView=[[UIView alloc] init];
                
                CGRect frame=self.timeField.frame;
                frame.size.width=60;
                [leftView setFrame:frame];
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, (46-26)/2, 60, 26)];
                [lab setText:@"时间"];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setTextColor:[UIColor whiteColor]];
                [leftView addSubview:lab];
                self.timeField.leftViewMode=UITextFieldViewModeAlways;
                self.timeField.leftView=leftView;
                [self.timeField setDelegate:self];
                [cell addSubview:self.timeField];
            }
                break;
            case 2:
            {
                self.picField=[[UITextField alloc] initWithFrame:CGRectMake(20,(58-46)/2, bounds.size.width-75, 46)];
                [self.picField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
                [self.picField setTextColor:TAB_BACKGROUND_COLOR];
                [self.picField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.picField setTag:PIC_FIELD];
                [self.picField setPlaceholder:@"从相册选择"];
                
                [self.picField setBorderStyle:UITextBorderStyleNone];
                [self.picField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.picField setReturnKeyType:UIReturnKeyDone];
                [self.picField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [self.picField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
                [self.picField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
                [self.picField setEnabled:YES];
                [self.picField addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventEditingDidBegin];
                
                
                UIView *leftView=[[UIView alloc] init];
                
                CGRect frame=self.picField.frame;
                frame.size.width=60;
                [leftView setFrame:frame];
                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(5, (46-26)/2, 60, 26)];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setText:@"图片"];
                [lab setTextAlignment:NSTextAlignmentCenter];
                [lab setTextColor:[UIColor whiteColor]];
                [leftView addSubview:lab];
                self.picField.leftViewMode=UITextFieldViewModeAlways;
                self.picField.leftView=leftView;
                [self.picField setDelegate:self];
                [cell addSubview:self.picField];
                if (self.picImage) {
                    [cell addSubview:self.picImage];
                }
                if (self.picButton) {
                    [cell addSubview:self.picButton];
                }
                
                [cell addSubview:self.cameraButton];
            }
                break;
            case 3:
            {
                self.contentField=[[UITextView alloc] initWithFrame:CGRectMake(20,5, bounds.size.width-40, 190)];
                ;
                [self.contentField setBackgroundColor:[UIColor clearColor]];
                [self.contentField setTextColor:TAB_BACKGROUND_COLOR];
                [self.contentField setAutocorrectionType:UITextAutocorrectionTypeNo];
                [self.contentField setTag:CONTENT_FIELD];
                [self.contentField setFont:[UIFont systemFontOfSize:14.0f]];
                [self.contentField setReturnKeyType:UIReturnKeyDone];
                [self.contentField setKeyboardType:UIKeyboardTypeDefault];
                self.contentField.layer.cornerRadius = 6;
                self.contentField.layer.masksToBounds = YES;
                
                UIColor *customColor  = [UIColor colorWithRed:123/255.0 green:123/255.0 blue:123/255.0 alpha:1.0];
                self.contentField.layer.borderColor = customColor.CGColor;
                self.contentField.layer.borderWidth = 1.0;
                
            
                if (contentStr) {
                    [self.contentField setText:contentStr];
                }
                
                [self.contentField setDelegate:self];
                [cell addSubview:self.contentField];
                
                [cell addSubview:self.contentTip];
                break;
            }
            case 4:{
                self.sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
                [self.sendButton setFrame:CGRectMake(20, (58-36)/2, bounds.size.width-40, 36)];
                [self.sendButton setTitle:@"上传" forState:UIControlStateNormal];
                [self.sendButton  primaryStyle];
                
                [self.sendButton addTarget:self action:@selector(uploadRequest) forControlEvents:UIControlEventTouchUpInside];
                
                [cell addSubview:self.sendButton];
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

-(void)showImagePicker:(BOOL)isCamera
{
    BOOL hasCamera=[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera) {
        [self alertRequestResult:@"对不起,拍照功能不支持" isPop:NO];
    }
    UIImagePickerController* dController=[[UIImagePickerController alloc]init];
    dController.delegate=self;
    if (hasCamera&&isCamera) {
        dController.sourceType=UIImagePickerControllerSourceTypeCamera;
    }else{
        dController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
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
        if (self.picImage) {
            [self.picImage setImage:[UIImage imageNamed:filePath]];
        }
    }
}

-(void)didChangeTag:(id)sender
{
//    UITextField* field=(UITextField*)sender;
//    [field resignFirstResponder];
    [self hideKey];
    if (IOS_VERSION_8) {
        if (alertController==nil) {
            alertController=[UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        }
        [alertController.view removeFromSuperview];
        
        UIPickerView* dataPicker=[[UIPickerView alloc]init];
        dataPicker.backgroundColor=[UIColor whiteColor];
        dataPicker.tag=10002;
        dataPicker.delegate=self;
        dataPicker.dataSource=self;
//        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
//        }];
        [alertController.view addSubview:dataPicker];
//        [alert addAction:cancelAction];
        [self presentViewController:alertController animated:NO completion:^{
            
        }];
        
    }else{
        NSString* title=UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n\n\n":@"\n\n\n\n\n\n\n\n\n\n\n";
        UIActionSheet* sheet=[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"选择" otherButtonTitles:nil];
        sheet.actionSheetStyle=UIActionSheetStyleAutomatic;
        UIPickerView* dataPicker=[[UIPickerView alloc]init];
        dataPicker.tag=10002;
        dataPicker.dataSource=self;
        dataPicker.delegate=self;
        [sheet addSubview:dataPicker];
        [sheet showInView:self.view];
    }
}

#pragma mark - UIPickViewDatasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 3;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return @"活动";
        case 1:
            return @"优惠";
        default:
            return @"其他";
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            tagNameStr=@"活动";
            break;
        case 1:
            tagNameStr=@"优惠";
            break;
        default:
            tagNameStr=@"其他";
            break;
    }
    [mTableView reloadData];
    [alertController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)didChangeDate:(id)sender
{
    UITextField* field=(UITextField*)sender;
    [field resignFirstResponder];
    if (IOS_VERSION_8) {
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIDatePicker* datePicker=[[UIDatePicker alloc]init];
        datePicker.datePickerMode=UIDatePickerModeDate;
        datePicker.backgroundColor=[UIColor whiteColor];
        datePicker.tag=10001;
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSDateFormatter* formatter=[[NSDateFormatter alloc]init];
            formatter.dateFormat=@"yyyy-MM-dd";
            NSTimeZone* timezone=[NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
            [formatter setTimeZone:timezone];
            NSString *dateTemp=[formatter stringFromDate:datePicker.date];
            [self.timeField setText:dateTemp];
            timeStr=dateTemp;
        }];
        [alert.view addSubview:datePicker];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:NO completion:^{
            
        }];
    }else{
        NSString* title=UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n\n\n":@"\n\n\n\n\n\n\n\n\n\n\n";
        UIActionSheet* sheet=[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"OK" otherButtonTitles:nil];
        sheet.actionSheetStyle=UIActionSheetStyleAutomatic;
        UIDatePicker* datePicker=[[UIDatePicker alloc]init];
        datePicker.datePickerMode=UIDatePickerModeDate;
        datePicker.tag=10001;
        [sheet addSubview:datePicker];
        [sheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIDatePicker* datePicker=(UIDatePicker*)[actionSheet viewWithTag:10001];
    if (datePicker) {
        NSDateFormatter* formatter=[[NSDateFormatter alloc]init];
        formatter.dateFormat=@"yyyy-MM-dd";
        NSTimeZone *timezone=[NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [formatter setTimeZone:timezone];
        NSString *dateTemp=[formatter stringFromDate:datePicker.date];
        [self.timeField setText:dateTemp];
        timeStr=dateTemp;
    }
}

-(void)hideKey
{
    for (UIView* view in mTableView.subviews) {
        if (iOS_VERSION_7) {
            for (UIView* v in view.subviews) {
                if ([v isKindOfClass:[UITableViewCell class]]) {
                    for (UIView* v1 in v.subviews) {
                        DLog(@"%@",v1);
                        for (UIView* v2 in v1.subviews) {
                            if ([v2 isKindOfClass:[UITextField class]]) {
                                [(UITextField*)v2 resignFirstResponder];
                            }
                        }
                        if ([v1 isKindOfClass:[UITextField class]]) {
                            [((UITextField*)v1) resignFirstResponder];
                        }
                    }
                }
            }
        }else{
            if ([view isKindOfClass:[UITableViewCell class]]) {
                for (UIView* v1 in view.subviews) {
                    if ([v1 isKindOfClass:[UITextField class]]) {
                        [(UITextField*)v1  resignFirstResponder];
                    }
                }
            }
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
    if (textField.tag==MALL_FIELD||textField.tag==BRAND_FIELD||textField.tag==TIME_FIELD) {
        [[self valueForKey:@"picButton"] setHidden:NO];
        [[self valueForKey:@"tagButton"] setHidden:NO];
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag==MALL_FIELD) {
        mallNameStr=[NSString stringWithFormat:@"%@",textField.text];
    }
    else if (textField.tag==BRAND_FIELD) {
        brandNameStr=[NSString stringWithFormat:@"%@",textField.text];
    }
    if (textField.tag==TIME_FIELD) {
        timeStr=[NSString stringWithFormat:@"%@",textField.text];
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.contentTip removeFromSuperview];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.tag==CONTENT_FIELD) {
        contentStr=textView.text;
    }
}

@end
