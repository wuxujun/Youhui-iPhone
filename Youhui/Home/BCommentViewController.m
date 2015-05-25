//
//  BCommentViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/18.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BCommentViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "BrandTViewController.h"
#import "WebViewController.h"
#import "BrandHeadView.h"
#import "UIView+LoadingView.h"
#import "UMSocial.h"
#import "CollectEntity.h"
#import "CommentEViewController.h"

@interface BCommentViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,BrandHeadViewDelegate>
{
    int         brandId;
    int         mallId;
    BrandHeadView*          headView;
}
@end

@implementation BCommentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addBackBarButton];
    datas=[[NSMutableArray alloc]init];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"评论" style:UIBarButtonItemStylePlain target:self action:@selector(comment:)];
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=(id<UITableViewDelegate>)self;
        mTableView.dataSource=(id<UITableViewDataSource>)self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        [self.view addSubview:mTableView];
    }
    
    if (headView==nil) {
        headView=[[BrandHeadView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) delegate:self];
    }
    [mTableView setTableHeaderView:headView];
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    if (self.infoDict) {
        [headView setDict:self.infoDict];
        titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [titleLabel setText:[self.infoDict objectForKey:@"brandName"]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=titleLabel;
        if ([self.infoDict objectForKey:@"sid"]) {
            mallId=[[self.infoDict objectForKey:@"sid"] intValue];
        }else{
            mallId=[[self.infoDict objectForKey:@"mallId"] intValue];
        }
        if ([self.infoDict objectForKey:@"bid"]) {
            brandId=[[self.infoDict objectForKey:@"bid"] intValue];
        }else{
            brandId=[[self.infoDict objectForKey:@"brandId"] intValue];
        }
    }
    
}

-(IBAction)comment:(id)sender
{
    CommentEViewController* dController=[[CommentEViewController alloc]init];
    dController.infoDict=self.infoDict;
    [self.navigationController pushViewController:dController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestData
{
    NSString *url = [NSString stringWithFormat:@"%@comment",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",mallId],@"mallId",[NSString stringWithFormat:@"%d",brandId],@"brandId", nil]];
    [self.view showHUDLoadingView:YES];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        DLog(@"%@",result);
        NSDictionary* rs=(NSDictionary*)result;
        id  dc=[rs objectForKey:@"brandInfo"];
        if ([dc isKindOfClass:[NSDictionary class]]) {
            [headView setDict:dc];
            [titleLabel setText:[dc objectForKey:@"brandName"]];
        }
        NSArray * arr=[rs objectForKey:@"root"];
        [datas addObjectsFromArray:arr];
        [mTableView reloadData];
        [self.view showHUDLoadingView:NO];
    } error:^(NSError *error) {
        DLog(@"get home fail");
        [self alertRequestResult:@"数据请求失败." isPop:NO];
    }];
}

-(CGFloat)cellHeight:(NSString*)text{
    UILabel *lable=[[UILabel alloc]init];
    lable.text=text;
    lable.numberOfLines = 10;
    CGSize size = CGSizeMake(self.view.frame.size.width-60, 1000);
    CGSize labelSize = [lable.text sizeWithFont:lable.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    lable.frame = CGRectMake(lable.frame.origin.x, lable.frame.origin.y, labelSize.width, labelSize.height);
    return labelSize.height+10;
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic=[datas objectAtIndex:indexPath.row];
    return [self cellHeight:[dic objectForKey:@"comment"]]+44.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect bounds=self.view.frame;
    if (section==0) {
        UIView* view=[[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,32)];
        view.backgroundColor=TABLE_HEAD_BACKGROUND_COLOR;
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20,(32-26)/2, 200, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:14.0f]];
        [label setText:@"评论列表"];
        [view addSubview:label];
        return view;
    }
    return nil;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    CGRect bounds=self.view.frame;
    NSDictionary* dic=[datas objectAtIndex:indexPath.row];
   float h=44.0;
    if (dic) {
        h=[self cellHeight:[dic objectForKey:@"comment"]];
        
        UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 36, 36)];
        [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        img.layer.cornerRadius=18;
        img.layer.masksToBounds=YES;
        [cell addSubview:img];
        
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(50, 5, 100, 26)];
        [label setText:[dic objectForKey:@"adduser"]];
        [label setFont:[UIFont systemFontOfSize:14.0]];
        [label setTextColor:[UIColor whiteColor]];
        [cell addSubview:label];
        
        UILabel* desc=[[UILabel alloc]initWithFrame:CGRectMake(50, 30, bounds.size.width-60, h)];
        [desc setText:[dic objectForKey:@"comment"]];
        [desc setTextColor:[UIColor whiteColor]];
        [cell addSubview:desc];
        
        UILabel* time=[[UILabel alloc]initWithFrame:CGRectMake(bounds.size.width-150, 5, 140, 26)];
        NSString* t=[NSString stringWithFormat:@"%@",[dic objectForKey:@"addtime"]];
        [time setText:[t substringToIndex:[t length]-3]];
        [time setFont:[UIFont systemFontOfSize:12.0]];
        [time setTextColor:[UIColor whiteColor]];
        [time setTextAlignment:NSTextAlignmentRight];
        [cell addSubview:time];
    }
    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, h+43, bounds.size.width, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)onBrandHeadViewClicked:(BrandHeadView *)view
{
    
}



@end
