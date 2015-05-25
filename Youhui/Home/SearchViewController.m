//
//  SearchViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+NavigationBarButton.h"
#import "MallViewController.h"
#import "BrandViewController.h"
#import "HTapRateView.h"
#import "UIView+LoadingView.h"

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString        *searchKey;
    NSString        *searchType;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    searchType=@"0";
    if (self.infoDict) {
        searchKey=[self.infoDict objectForKey:@"searchKey"];
        searchType=[self.infoDict objectForKey:@"searchType"];
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:[self.infoDict objectForKey:@"title"]];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;

    }
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];

    [self requestData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString *url = [NSString stringWithFormat:@"%@search",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:searchKey,@"searchKey", searchType,@"type",nil]];
    [self.view showHUDLoadingView:YES];
    __weak SearchViewController* myself=self;
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
//        DLog(@"%@",result);
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        [datas addObjectsFromArray:arr];
        [self refresh];
    } error:^(NSError *error) {
        DLog(@"get home fail");
        [myself.view showHUDLoadingView:NO];
    }];
}

-(void)refresh
{
    [self.view showHUDLoadingView:NO];
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
        UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 4, 56, 56)];
        [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        if ([searchType isEqualToString:@"2"]) {
            [img setImageWithURL:[NSURL URLWithString:@"mallLogo"] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        }
        img.layer.cornerRadius=28;
        img.layer.masksToBounds=YES;
        [cell addSubview:img];
        
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, bounds.size.width-100, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:18.0f]];
        [label setText:[NSString stringWithFormat:@"%@(%@)",[dic objectForKey:@"brandName"],[dic objectForKey:@"mallName"]]];
        if ([searchType isEqualToString:@"2"]) {
            [label setText:[dic objectForKey:@"mallName"]];
        }
        [cell addSubview:label];
        
        if ([dic objectForKey:@"rating"]) {
            HTapRateView* rate=[[HTapRateView alloc]initWithFrame:CGRectMake(80, 36, bounds.size.width/2, 30)];
            [rate setMax_star:5];
            [rate setShow_star:[[dic objectForKey:@"rating"] integerValue]];
            [cell addSubview:rate];
        }
        
//        UILabel* label1=[[UILabel alloc]initWithFrame:CGRectMake(80, 36, bounds.size.width-100, 26)];
//        [label1 setTextColor:[UIColor whiteColor]];
//        [label1 setFont:[UIFont systemFontOfSize:14.0f]];
//        [label1 setText:[dic objectForKey:@"mallName"]];
//        if ([searchType isEqualToString:@"2"]) {
//            [label1 setText:[dic objectForKey:@"address"]];
//        }
//        [cell addSubview:label1];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dic=[datas objectAtIndex:indexPath.row];
    if (dic) {
        if ([searchType isEqualToString:@"2"]) {
            MallViewController* dController=[[MallViewController alloc]init];
            dController.infoDict=dic;
            [self.navigationController pushViewController:dController animated:YES];
        }else if([searchType isEqualToString:@"0"]){
            BrandViewController* dController=[[BrandViewController alloc]init];
            dController.infoDict=dic;
            [self.navigationController pushViewController:dController animated:YES];
        }
    }
}


@end
