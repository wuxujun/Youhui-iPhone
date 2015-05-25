//
//  BrandTCViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/20.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BrandTCViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import <QuartzCore/QuartzCore.h>
#import "TItemView.h"
#import "YSearchDisplayController.h"
#import "UIImageView+AFNetworking.h"
#import "HNetworkEngine.h"
#import "BrandViewController.h"

@interface BrandTCViewController()<UITableViewDataSource,UITableViewDelegate,TItemViewDelegate>
{
    int             mallId;
    int             brandId;
}

@end

@implementation BrandTCViewController

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
        mTableView.rowHeight=165;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
        [self.view addSubview:mTableView];
    }
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    if (self.infoDict) {
        mallId=[[self.infoDict objectForKey:@"mallId"] intValue];
        brandId=[[self.infoDict objectForKey:@"brandId"] intValue];
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, self.view.frame.size.width-120, 34)];
        [lab setText:[self.infoDict objectForKey:@"title"]];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
    }
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
    NSString *url = [NSString stringWithFormat:@"%@mallBrandTop",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.type,@"type",[NSString stringWithFormat:@"%d",mallId],@"mallId",[NSString stringWithFormat:@"%d",brandId],@"brandId",nil]];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        DLog(@"%@",result);
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        [datas addObjectsFromArray:arr];
        [self refresh];
    } error:^(NSError *error) {
        DLog(@"get message fail");
    }];
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
    int count=[datas count];
    return count%2==0?count/2:count/2+1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CGRect bounds=self.view.frame;
    cell.backgroundColor=[UIColor clearColor];
    for (int i=indexPath.row*2; i<(indexPath.row+2)&&i<[datas count]; i++) {
        NSDictionary * dic=[datas objectAtIndex:i];
        if (dic) {
            TItemView *item=[[TItemView alloc]initWithFrame:CGRectMake(0, 0,bounds.size.width/2 , 165) delegate:self];
            item.dict=dic;
            [cell addSubview:item];
        }
    }
    
//    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(70, 63, bounds.size.width-70, 1)];
//    [line setBackgroundColor:TABLE_BACKGROUND_COLOR];
//    [cell addSubview:line];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
//    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //    NSDictionary * dic=[datas objectAtIndex:indexPath.row];
    //    if (dic) {
    //        BrandViewController* dController=[[BrandViewController alloc]init];
    //        dController.infoDict=dic;
    //        [self.navigationController pushViewController:dController animated:YES];
    //    }
}

-(void)onTItemViewClicked:(TItemView *)view
{
    
}

@end
