//
//  SaleViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "SaleViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "UserDefaultHelper.h"
#import "UIImageView+AFNetworking.h"
#import "SearchViewController.h"

#import "UIView+LoadingView.h"

@interface SaleViewController()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIBarButtonItem     *cityButton;
    
    NSString            *currentCityCode;
    NSString            *currentCityName;
}

@end

@implementation SaleViewController

-(id)init
{
    self=[super init];
    if (self) {
        self.title=@"优惠";
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:@"优惠"];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
        [self.tabBarItem setImage:[UIImage imageNamed:@"Sale"]];
        [self.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    datas=[[NSMutableArray alloc]init];
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_nav_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(openCamera:)];
    
//    cityButton=[[UIBarButtonItem alloc]initWithTitle:@"杭州" style:UIBarButtonItemStylePlain target:self action:@selector(citySelect:)];
//    [cityButton setTintColor:[UIColor whiteColor]];
//    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:cityButton, nil];
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    DLog(@"%f   %f    %f",self.view.frame.size.height,self.navigationController.navigationBar.frame.size.height,self.tabBarController.tabBar.frame.size.height);
    cellHeight=(self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-20)/4;
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=(id<UITableViewDelegate>)self;
        mTableView.dataSource=(id<UITableViewDataSource>)self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.rowHeight=cellHeight;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        
        [self.view addSubview:mTableView];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString* cityCode;
    NSString* cityName;
    if ([UserDefaultHelper objectForKey:CURRENT_CITY_CODE]) {
        cityCode=[UserDefaultHelper objectForKey:CURRENT_CITY_CODE];
    }
    if ([UserDefaultHelper objectForKey:CURRENT_CITY_TITLE]) {
        cityName=[UserDefaultHelper objectForKey:CURRENT_CITY_TITLE];
        [cityButton setTitle:cityName];
    }
    if ([cityCode isEqual:currentCityCode]) {
        
    }else{
        currentCityCode=cityCode;
        currentCityName=cityName;
        [self loadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeCenterSearchBar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    [datas removeAllObjects];
    NSString *url = [NSString stringWithFormat:@"%@sales",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"571",@"city", nil]];
    [self.view showHUDLoadingView:YES];
    __weak SaleViewController* myself=self;
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        DLog(@"%@",result);
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        [datas addObjectsFromArray:arr];
        [mTableView reloadData];
        [myself.view showHUDLoadingView:NO];
    } error:^(NSError *error) {
        DLog(@"get home fail");
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
    UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, cellHeight-1)];
    [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_cell_normal"]];
    [cell addSubview:img];
    
    UIImageView* bg=[[UIImageView alloc]initWithFrame:CGRectMake(bounds.size.width*0.6,cellHeight-70, bounds.size.width*0.4, 50)];
    [bg setImage:[[UIImage imageNamed:@"ic_map_title_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    [cell addSubview:bg];
    
    UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(bounds.size.width*0.6, cellHeight-70, bounds.size.width*0.4, 30)];
    [lb setFont:[UIFont boldSystemFontOfSize:18]];
    [lb setTextColor:[UIColor whiteColor]];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [lb setText:[dic objectForKey:@"brandName"]];
    [cell addSubview:lb];
    
    UILabel* lb1=[[UILabel alloc]initWithFrame:CGRectMake(bounds.size.width*0.6, cellHeight-46, bounds.size.width*0.4, 30)];
    [lb1 setFont:[UIFont systemFontOfSize:16]];
    [lb1 setTextColor:[UIColor whiteColor]];
    [lb1 setTextAlignment:NSTextAlignmentCenter];
    [lb1 setText:[dic objectForKey:@"title"]];
    [cell addSubview:lb1];
    
    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, cellHeight-1, bounds.size.width, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
//    if (indexPath.row%2==0) {
//        UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width/2, cellHeight)];
//        [iv setImage:[UIImage imageNamed:@"ic_sale_left"]];
//        [iv setContentMode:UIViewContentModeScaleToFill];
//        [cell addSubview:iv];
//        
//        UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(0, cellHeight/2-20, bounds.size.width/2, 30)];
//        [lb setFont:[UIFont systemFontOfSize:16]];
//        [lb setTextAlignment:NSTextAlignmentCenter];
//        [lb setText:[dic objectForKey:@"brandName"]];
//        [cell addSubview:lb];
//        
//        UILabel* lb1=[[UILabel alloc]initWithFrame:CGRectMake(0, cellHeight/2, bounds.size.width/2, 30)];
//        [lb1 setFont:[UIFont systemFontOfSize:16]];
//        [lb1 setTextAlignment:NSTextAlignmentCenter];
//        [lb1 setText:[dic objectForKey:@"title"]];
//        [cell addSubview:lb1];
//        
//    }else{
//       
//        UIImageView* iv=[[UIImageView alloc]initWithFrame:CGRectMake(bounds.size.width/2, 0, bounds.size.width/2, cellHeight)];
//        [iv setImage:[UIImage imageNamed:@"ic_sale_right"]];
//        [iv setContentMode:UIViewContentModeScaleToFill];
//        [cell addSubview:iv];
//    
//        UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(bounds.size.width/2, cellHeight/2-20, bounds.size.width/2, 30)];
//        [lb setFont:[UIFont systemFontOfSize:16]];
//        [lb setTextAlignment:NSTextAlignmentCenter];
//        [lb setText:[dic objectForKey:@"brandName"]];
//        [cell addSubview:lb];
//        
//        UILabel* lb1=[[UILabel alloc]initWithFrame:CGRectMake(bounds.size.width/2, cellHeight/2, bounds.size.width/2, 30)];
//        [lb1 setFont:[UIFont systemFontOfSize:16]];
//        [lb1 setTextAlignment:NSTextAlignmentCenter];
//        [lb1 setText:[dic objectForKey:@"title"]];
//        [cell addSubview:lb1];
//
//    }
//   
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dic=[datas objectAtIndex:indexPath.row];
    SearchViewController* dController=[[SearchViewController alloc]init];
    dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"brandName"],@"searchKey",[dic objectForKey:@"brandName"],@"title",@"0",@"searchType",nil];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

@end
