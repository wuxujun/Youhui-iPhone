//
//  MapCateViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/7.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MapCateViewController.h"
#import "MItemView.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "HNetworkEngine.h"
#import "UIImageView+AFNetworking.h"
#import "MapCateLViewController.h"


@interface MapCateViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int                 mallId;
}
@end

@implementation MapCateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    datas=[[NSMutableArray alloc] init];
    [self addBackBarButton];
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mTableView.rowHeight=125.0;
        [self.view addSubview:mTableView];
    }
    if (self.infoDict) {
        DLog(@"%@",self.infoDict);
        if ([self.infoDict objectForKey:@"mid"]) {
            mallId=[[self.infoDict objectForKey:@"mid"] intValue];
        }else if ([self.infoDict objectForKey:@"mallId"]){
            mallId=[[self.infoDict objectForKey:@"mallId"] intValue];
        }else{
            mallId=[[self.infoDict objectForKey:@"id"] intValue];
        }
    }
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    [self requestData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestData
{
    NSString *url = [NSString stringWithFormat:@"%@mallCates",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",mallId],@"mallId", nil]];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        [datas addObjectsFromArray:arr];
        [self refresh];
    } error:^(NSError *error) {
        DLog(@"get home fail");
    }];
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
    NSDictionary* dic=[datas objectAtIndex:indexPath.row];
    UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, 125)];
    if (dic) {
        [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_cell_normal"]];
    }else{
        [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"1%ld.jpg",(indexPath.row+1)]]];
    }
    [cell addSubview:img];
    
    
//    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, (110-26)/2, cell.frame.size.width, 26)];
//    [label setTextColor:[UIColor whiteColor]];
//    [label setTextAlignment:NSTextAlignmentCenter];
//    [label setFont:[UIFont systemFontOfSize:16.0f]];
//    [label setText:@"男装"];
//    [cell addSubview:label];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dic=[datas objectAtIndex:indexPath.row];
    MapCateLViewController* dController=[[MapCateLViewController alloc]init];
    dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",mallId],@"id",[dic objectForKey:@"code"],@"code",[dic objectForKey:@"category"],@"category", nil];
    [self.navigationController pushViewController:dController animated:YES];
}


@end
