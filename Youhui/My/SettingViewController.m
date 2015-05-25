//
//  SettingViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/18.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "SettingViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "BrandTViewController.h"
#import "WebViewController.h"
#import "BrandHeadView.h"
#import "UIView+LoadingView.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addBackBarButton];
    datas=[[NSMutableArray alloc]init];
    
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, self.view.frame.size.width-120, 34)];
    [lab setText:@"设置"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    
    

    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=(id<UITableViewDelegate>)self;
        mTableView.dataSource=(id<UITableViewDataSource>)self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        [self.view addSubview:mTableView];
    }
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 44.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect bounds=self.view.frame;
    NSString* title=@"图片显示";
    if (section==1) {
        title=@"消息提醒";
    }
    UIView* view=[[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,32)];
    view.backgroundColor=TABLE_HEAD_BACKGROUND_COLOR;
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20,(32-26)/2, 200, 26)];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:14.0f]];
    [label setText:title];
    [view addSubview:label];
    return view;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    CGRect bounds=self.view.frame;
    NSArray *titles = @[@"2G/3G/4G网络下显示图片",@"消息推送"];
    
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20, (44-26)/2, bounds.size.width-40, 26)];
    [label setText:titles[indexPath.section]];
    [label setFont:[UIFont systemFontOfSize:16.0]];
    [label setTextColor:[UIColor whiteColor]];
    [cell addSubview:label];
    
    UISwitch* sw=[[UISwitch alloc]initWithFrame:CGRectMake(bounds.size.width-80, 6, 60, 30)];
    [cell addSubview:sw];

    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, bounds.size.width, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
