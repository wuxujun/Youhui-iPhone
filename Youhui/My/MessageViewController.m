//
//  MessageViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/30.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MessageViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MItemView.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "UIImageView+AFNetworking.h"
#import "HNetworkEngine.h"
#import "BrandViewController.h"

@interface MessageViewController()<UITableViewDataSource,UITableViewDelegate>
{
    int             msgType;
}

@end

@implementation MessageViewController

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
    msgType=0;
    
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
    if (self.infoDict) {
        DLog(@"%@",self.infoDict);
        msgType=[[self.infoDict objectForKey:@"type"] intValue];
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
    NSString *url = [NSString stringWithFormat:@"%@messages",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",msgType],@"type",nil]];
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
        [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        img.layer.cornerRadius=28;
        img.layer.masksToBounds=YES;
        [cell addSubview:img];
        
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, bounds.size.width-100, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:18.0f]];
        [label setText:[dic objectForKey:@"title"]];
        [cell addSubview:label];
        
        UILabel* label1=[[UILabel alloc]initWithFrame:CGRectMake(80, 36, bounds.size.width-100, 26)];
        [label1 setTextColor:[UIColor whiteColor]];
        [label1 setFont:[UIFont systemFontOfSize:14.0f]];
        [label1 setText:[dic objectForKey:@"content"]];
        [cell addSubview:label1];
        
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
//    NSDictionary * dic=[datas objectAtIndex:indexPath.row];
//    if (dic) {
//        BrandViewController* dController=[[BrandViewController alloc]init];
//        dController.infoDict=dic;
//        [self.navigationController pushViewController:dController animated:YES];
//    }
}

@end
