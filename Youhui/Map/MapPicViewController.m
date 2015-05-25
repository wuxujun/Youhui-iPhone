//
//  MapPicViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/19.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MapPicViewController.h"
#import "MItemView.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "HNetworkEngine.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+Addition.h"
#import "PathHelper.h"
#import "UIFont+Setting.h"

#define NOT_EXPANDING 100
#define IS_EXPANDING 101

@interface MapPicViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int                 mallId;
    
    NSMutableDictionary          *status;
}

@end

@implementation MapPicViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    datas=[[NSMutableArray alloc] init];
    status=[NSMutableDictionary dictionary];
    [self addBackBarButton];
    
     cellHeight=self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-20;
    cellHeight=self.view.frame.size.height;
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.rowHeight=cellHeight;
        [self.view addSubview:mTableView];
    }
    if (self.infoDict) {
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
    NSString *url = [NSString stringWithFormat:@"%@mallFloors",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",mallId],@"mallId", nil]];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        DLog(@"%@",result);
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
    for (int i=0; i<[datas count]; i++) {
        [status setValue:@"1" forKey:[NSString stringWithFormat:@"key_%d",i]];
    }
    [mTableView reloadData];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [datas count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int state=[[status objectForKey:[NSString stringWithFormat:@"key_%d",section]] intValue];
    if (state==1) {
        return 1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.bounds.size.height;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect bounds=self.view.frame;
    NSDictionary* dic=[datas objectAtIndex:section];
    if (dic) {
        UIView* view=[[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,44)];
        view.backgroundColor=TABLE_HEAD_BACKGROUND_COLOR;
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20,(44-26)/2, 200, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:14.0f]];
        [label setText:[dic objectForKey:@"floorName"]];
        [view addSubview:label];
        
        UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(0, 0, bounds.size.width, 44)];
        button.tag=section;
        [button addTarget:self action:@selector(headerClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        UIImageView* arrow=[[UIImageView alloc]initWithFrame:CGRectMake(bounds.size.width-40, (44-16)/2, 22, 16)];
        arrow.tag=101;
        if ([[status objectForKey:[NSString stringWithFormat:@"key_%d",section]] intValue]==1) {
            arrow.image = [UIImage imageNamed:@"ic_arrow_up"];
        }else{
            arrow.image = [UIImage imageNamed:@"ic_arrow_down"];
        }
        [view addSubview:arrow];
        
        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, bounds.size.width, 1)];
        [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
        [view addSubview:line];
        return view;
    }
    return nil;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGRect bounds=self.view.frame;
    NSDictionary* dic=[datas objectAtIndex:indexPath.section];
    NSString *CellIdentifer = [NSString stringWithFormat:@"CellIdentifier%ld", indexPath.section];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    if (dic) {
        UIImageView* img=[[UIImageView alloc]initWithFrame:self.view.bounds];
        img.tag=101;
        [img setContentMode:UIViewContentModeScaleAspectFill];
        [img setClipsToBounds:YES];
        [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]]];
        [cell addSubview:img];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row==0) {
//        NSInteger section=indexPath.section;
//        UIWebView* webView=[self webViewInSection:section];
//        NSIndexPath *indexPathToChange=[NSIndexPath indexPathForRow:1 inSection:section];
//        UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
//        cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
//        UIImageView * arrow=(UIImageView*)[cell.contentView viewWithTag:101];
//        if (webView.tag==IS_EXPANDING) {
//            webView.tag=NOT_EXPANDING;
//          arrow.image = [UIImage imageNamed:@"Arrow_down"];
//            [mTableView deleteRowsAtIndexPaths:@[indexPathToChange] withRowAnimation:UITableViewRowAnimationFade];
//        }else{
//            webView.tag=IS_EXPANDING;
//             arrow.image = [UIImage imageNamed:@"Arrow"];
//            [mTableView insertRowsAtIndexPaths:@[indexPathToChange] withRowAnimation:UITableViewRowAnimationFade];
//        }
//    }
}

-(IBAction)headerClicked:(id)sender
{
    int sectionIdx=((UIButton*)sender).tag;
    int state=[[status objectForKey:[NSString stringWithFormat:@"key_%d",sectionIdx]] intValue];
    if (state==1) {
        state=0;
    }else{
        state=1;
    }
    [status setValue:[NSString stringWithFormat:@"%d",state] forKey:[NSString stringWithFormat:@"key_%d",sectionIdx]];
    
    [mTableView reloadData];
    //    [mTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIdx] withRowAnimation:UITableViewRowAnimationTop];
}

@end
