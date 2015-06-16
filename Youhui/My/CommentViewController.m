//
//  CommentViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/17.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "CommentViewController.h"
#import "BrandViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "CollectEntity.h"
#import "HCurrentUserContext.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+LoadingView.h"

@interface CommentViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation CommentViewController

-(id)init
{
    self=[super init];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    datas=[[NSMutableArray alloc]init];
    [self addBackBarButton];
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.rowHeight=64;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        [self.view addSubview:mTableView];
    }
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, self.view.frame.size.width-120, 34)];
    [lab setText:@"我的评论"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    [self requestData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)requestData
{
    NSString *url = [NSString stringWithFormat:@"%@myComment",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionary];
    [params setObject:[NSString stringWithFormat:@"%@",[[HCurrentUserContext sharedInstance] uid] ] forKey:@"uid"];
    [self.view showHUDLoadingView:YES];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        DLog(@"%@",result);
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        [datas removeAllObjects];
        [datas addObjectsFromArray:arr];
        [mTableView reloadData];
        [self.view showHUDLoadingView:NO];
    } error:^(NSError *error) {
        DLog(@"get home fail");
        [self alertRequestResult:@"数据请求失败." isPop:NO];
    }];
}

-(void)loadData
{
    NSArray * ay=[CollectEntity MR_findAllSortedBy:@"id" ascending:YES];
    [datas addObjectsFromArray:ay];
    [mTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refresh
{
    [mTableView reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [datas count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CGRect bounds=self.view.frame;
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    NSDictionary * dic=[datas objectAtIndex:indexPath.row];
    if (dic) {
        
        UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, (64-48)/2, 48, 48)];
        [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kHttpImageUrl,[dic objectForKey:@"image"]]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        img.layer.cornerRadius=24;
        img.layer.masksToBounds=YES;
        [cell addSubview:img];
        
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, bounds.size.width-100, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:18.0f]];
        [label setText:[dic objectForKey:@"comment"]];
        [cell addSubview:label];
    }
    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(70, 63, bounds.size.width-70, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
