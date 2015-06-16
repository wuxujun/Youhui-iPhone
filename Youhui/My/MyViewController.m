//
//  MyViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MyViewController.h"
#import "MyHeadView.h"
#import "LoginViewController.h"
#import "RegViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "AppDelegate.h"
#import "CollectViewController.h"
#import "CommentViewController.h"
#import "SettingViewController.h"
#import "HCurrentUserContext.h"
#import "MyFindViewController.h"
#import "MyInfoViewController.h"

@interface MyViewController ()<UITableViewDataSource,UITableViewDelegate,MyHeadViewDelegate>

@property (nonatomic,strong)MyHeadView*  headView;
@end

@implementation MyViewController

-(id)init
{
    self=[super init];
    if (self) {
        self.title=@"我的";
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:@"我的信息"];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
        [self.tabBarItem setImage:[UIImage imageNamed:@"My"]];
//        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
        [self.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=RGBCOLOR(30, 33, 38);
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mTableView];
    }
    if (self.headView==nil) {
        self.headView=[[MyHeadView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150) delegate:self];
        [mTableView setTableHeaderView:self.headView];
    }

}

-(void)addLogoutButton
{
    UILabel* logout=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 26)];
    [logout setText:@"注销"];
    [logout setTextAlignment:NSTextAlignmentRight];
    [logout setTextColor:[UIColor whiteColor]];
    UIButton *rightBtn=[[UIButton alloc]init];
    [rightBtn setFrame:CGRectMake(0, 0,50, 30)];
    [rightBtn addSubview:logout];
    [rightBtn addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

-(IBAction)logout:(id)sender
{
    [[HCurrentUserContext sharedInstance] clearUserInfo];
    [self.headView  logout];
    self.navigationItem.rightBarButtonItem=nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[HCurrentUserContext sharedInstance] uid]) {
        [self addLogoutButton];
        [self.headView refresh];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define SEARCH_VIEW_TAG 100
-(void)goSearch
{
 
}

-(void)onMyHeadViewLoginClicked
{
    LoginViewController* dController=[[LoginViewController alloc]init];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

-(void)onMyHeadViewRegisterClicked
{
    RegViewController* dController=[[RegViewController alloc]init];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

-(void)onMyHeadViewAvatarClicked
{
    
}

-(void)onMyHeadViewClicked
{
    MyInfoViewController*   dController=[[MyInfoViewController alloc]init];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 10.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=RGBCOLOR(41, 44, 49);
    CGRect bounds=self.view.frame;
    
    NSArray *titles = @[@"我的发现"];
    NSArray *images=@[@"ic_my_1",@"ic_my_1"];
    if (indexPath.section==1) {
        titles=@[@"我的收藏",@"我的评论"];
        images=@[@"ic_my_2",@"ic_my_3"];
    }else if(indexPath.section==2){
        titles=@[@"设置",@"客服电话"];
        images=@[@"ic_my_5",@"ic_my_6"];
    }
    UIImageView* icon=[[UIImageView alloc]initWithFrame:CGRectMake(10, (44-24)/2, 24, 24)];
    [icon setImage:[UIImage imageNamed:images[indexPath.row]]];
    [cell addSubview:icon];
    
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(50, (44-26)/2, 200, 26)];
    [label setText:titles[indexPath.row]];
    [label setTextColor:[UIColor whiteColor]];
    [cell addSubview:label];
    
    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, bounds.size.width, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            if ([[HCurrentUserContext sharedInstance] uid]) {
                MyFindViewController* dController=[[MyFindViewController alloc]init];
                dController.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:dController animated:YES];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_OpenLogin" object:nil userInfo:nil];
            }
        }
    }else if (indexPath.section==1) {
        if ([[HCurrentUserContext sharedInstance] uid]) {
            if (indexPath.row==0) {
                CollectViewController *dController=[[CollectViewController alloc]init];
                dController.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:dController animated:YES];
            }else if (indexPath.row==1){
                CommentViewController* dController=[[CommentViewController alloc]init];
                dController.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:dController animated:YES];
            }
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_OpenLogin" object:nil userInfo:nil];
        }
    }else if(indexPath.section==2){
        if(indexPath.row==0){
            SettingViewController* dController=[[SettingViewController alloc]init];
            [self.navigationController pushViewController:dController animated:YES ];
        }
    }
}


@end
