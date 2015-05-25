//
//  SaleLViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/25.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "SaleLViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UIImageView+AFNetworking.h"

@interface SaleLViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SaleLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    datas=[[NSMutableArray alloc]init];
    [self addBackBarButton];
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=(id<UITableViewDelegate>)self;
        mTableView.dataSource=(id<UITableViewDataSource>)self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        [self.view addSubview:mTableView];
    }
    
    if (self.infoDict) {
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:[self.infoDict objectForKey:@"brandName"]];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
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
    return [datas count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell setBackgroundColor:TABLE_BACKGROUND_COLOR];
    CGRect bounds=self.view.frame;
    
    NSDictionary* dic=[datas objectAtIndex:indexPath.row];
  
    UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 4, 56, 56)];
    [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
    img.layer.cornerRadius=28;
    img.layer.masksToBounds=YES;
    [cell addSubview:img];
    
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, cell.frame.size.width-100, 26)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:18.0f]];
    [label setText:[dic objectForKey:@"brandName"]];
    [cell addSubview:label];
    
    UILabel* label1=[[UILabel alloc]initWithFrame:CGRectMake(80, 36, cell.frame.size.width-100, 26)];
    [label1 setTextColor:[UIColor whiteColor]];
    [label1 setFont:[UIFont systemFontOfSize:14.0f]];
    [label1 setText:[dic objectForKey:@"cateName"]];
    [cell addSubview:label1];

    
   
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


@end
