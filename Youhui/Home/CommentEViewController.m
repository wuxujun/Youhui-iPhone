//
//  CommentEViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/18.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "CommentEViewController.h"
#import "HKeyboardTableView.h"
#import "UIButton+Category.h"
#import "UIViewController+NavigationBarButton.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+LoadingView.h"
#import "HCurrentUserContext.h"

@interface CommentEViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    int         brandId;
    int         mallId;
}
@end

@implementation CommentEViewController

-(id)init
{
    self=[super init];
    if (self) {
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:@"填写评论"];
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
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(sendComment:)];
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
    
    if (self.infoDict) {
        if ([self.infoDict objectForKey:@"sid"]) {
            mallId=[[self.infoDict objectForKey:@"sid"] intValue];
        }else{
            mallId=[[self.infoDict objectForKey:@"mallId"] intValue];
        }
        if ([self.infoDict objectForKey:@"bid"]) {
            brandId=[[self.infoDict objectForKey:@"bid"] intValue];
        }else{
            brandId=[[self.infoDict objectForKey:@"brandId"] intValue];
        }
    }

}

-(IBAction)sendComment:(id)sender
{
    DLog(@"%@",self.infoDict);
    if (self.textField) {
        if (self.textField.text.length>0&&brandId>0) {
            DLog(@"%@",self.textField.text);
            
            NSString *url = [NSString stringWithFormat:@"%@addComment",kHttpUrl];
            NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",mallId],@"mallId",[NSString stringWithFormat:@"%d",brandId],@"brandId",self.textField.text,@"comment", nil]];
            if ([[HCurrentUserContext sharedInstance] uid]) {
                [params setObject:[[HCurrentUserContext sharedInstance] username] forKey:@"mobile"];
                [params setObject:[[HCurrentUserContext sharedInstance] uid] forKey:@"uid"];
            }
            
            [self.view showHUDLoadingView:YES];
            [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
//                DLog(@"%@",result);
//                NSDictionary* rs=(NSDictionary*)result;
                [self.view showHUDLoadingView:NO];
                [self alertRequestResult:@"评论提交成功" isPop:YES];
            } error:^(NSError *error) {
                DLog(@"get home fail");
                [self.view showHUDLoadingView:NO];
            }];
            
        }else{
            UIAlertView * aView=[[UIAlertView alloc]initWithTitle:@"请填写评论内容." message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [aView show];
        }
    }
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return 64;
    }
    return 210.0;
}

#define TEXT_FIELD  100

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
            UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 54, 54)];
            [img setImageWithURL:[NSURL URLWithString:[self.infoDict objectForKey:@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
            img.layer.cornerRadius=28;
            img.layer.masksToBounds=YES;
            [cell addSubview:img];
            
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(70, (64-26)/2, bounds.size.width-100, 26)];
            [label setTextColor:[UIColor whiteColor]];
            [label setFont:[UIFont systemFontOfSize:18.0f]];
            [label setText:[self.infoDict objectForKey:@"brandName"]];
            [cell addSubview:label];
            
            UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 63, bounds.size.width, 1)];
            [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
            [cell addSubview:line];
            break;
        }
        case 1:
        {
            
            self.textField=[[UITextField alloc] initWithFrame:CGRectMake(10, 5, bounds.size.width-20, 200)];
            [self.textField setBackground:[[UIImage imageNamed:@"ic_input_bg"] stretchableImageWithLeftCapWidth:24 topCapHeight:24]];
            [self.textField setTextColor:[UIColor whiteColor]];
            [self.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
            [self.textField setTag:TEXT_FIELD];
            [self.textField setPlaceholder:@"请填写评论"];
            [self.textField setBorderStyle:UITextBorderStyleNone];
            [self.textField setFont:[UIFont systemFontOfSize:16.0f]];
            [self.textField setReturnKeyType:UIReturnKeyDone];
            [self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
            [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
            [self.textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
            [self.textField becomeFirstResponder];
            
            UIView *leftView=[[UIView alloc]init];
            CGRect frame=self.textField.frame;
            frame.size.width=8;
            [leftView setFrame:frame];
            self.textField.leftViewMode=UITextFieldViewModeAlways;
            self.textField.leftView=leftView;
            
            [self.textField setDelegate:self];
            [cell addSubview:self.textField];
            UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 209, bounds.size.width, 1)];
            [img setImage:[UIImage imageNamed:@"contentview_topline"]];
            [cell addSubview:img];
            [cell sendSubviewToBack:img];
            UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 209, bounds.size.width, 1)];
            [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
            [cell addSubview:line];
            break;
        }
    }

    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"%@   %d",textField.text,[textField returnKeyType]);
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        
    }
}

@end
