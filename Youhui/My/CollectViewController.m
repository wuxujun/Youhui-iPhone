//
//  CollectViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/17.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "CollectViewController.h"
#import "BrandViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "CollectEntity.h"
#import "UIImageView+AFNetworking.h"

@interface CollectViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation CollectViewController

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
    [lab setText:@"我的收藏"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)loadData
{
    [datas removeAllObjects];
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
    CollectEntity * dic=[datas objectAtIndex:indexPath.row];
    if (dic) {
        DLog(@"%d",[dic.id intValue]);
        UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 4, 56, 56)];
        [img setImageWithURL:[NSURL URLWithString:dic.image] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        img.layer.cornerRadius=28;
        img.layer.masksToBounds=YES;
        [cell addSubview:img];
        
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, bounds.size.width-100, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:18.0f]];
        [label setText:dic.title];
        [cell addSubview:label];
        
    }
    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(70, 63, bounds.size.width-70, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CollectEntity * dic=[datas objectAtIndex:indexPath.row];
    if (dic) {
        DLog(@"%d",[dic.bid intValue]);
        BrandViewController* dController=[[BrandViewController alloc]init];
        dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",[dic.bid intValue]],@"brandId",[NSString stringWithFormat:@"%d",[dic.mid intValue]],@"mallId",[NSString stringWithFormat:@"%@",dic.title],@"brandName",[NSString stringWithFormat:@"%@",dic.image],@"brandLogo", nil];
        [self.navigationController pushViewController:dController animated:YES];
    }
}


@end
