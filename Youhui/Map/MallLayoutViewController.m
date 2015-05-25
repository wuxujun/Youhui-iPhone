//
//  MallLayoutViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MallLayoutViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MItemView.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "UIImageView+AFNetworking.h"
#import "HNetworkEngine.h"
#import "BrandViewController.h"

@interface MallLayoutViewController()<UITableViewDataSource,UITableViewDelegate>
{
    int             mallId;
    NSMutableDictionary          *status;
}

@end

@implementation MallLayoutViewController

-(id)init
{
    self=[super init];
    if (self) {
        self.title=@"Shopping Mall";
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    datas=[[NSMutableArray alloc]init];
    
    status=[NSMutableDictionary dictionary];
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
    if (self.infoDict) {
        if ([self.infoDict objectForKey:@"mid"]) {
            mallId=[[self.infoDict objectForKey:@"mid"] intValue];
        }else if ([self.infoDict objectForKey:@"mallId"]){
            mallId=[[self.infoDict objectForKey:@"mallId"] intValue];
        }else{
            mallId=[[self.infoDict objectForKey:@"id"] intValue];
        }
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
    NSString *url = [NSString stringWithFormat:@"%@mallBrandCate",kHttpUrl];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSDictionary* dic=[datas objectAtIndex:section];
        if (dic) {
            NSArray* array=(NSArray*)[dic objectForKey:@"cates"];
            return [array count];
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
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
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    [cell removeFromSuperview];
    CGRect bounds=self.view.frame;
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    int idx=indexPath.row;
    NSDictionary * dic=[datas objectAtIndex:indexPath.section];
    if (dic) {
        NSArray* array=(NSArray*)[dic objectForKey:@"cates"];
        
        NSDictionary* dc=[array objectAtIndex:idx>[array count]?0:idx];
        
        UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 4, 56, 56)];
        [img setImageWithURL:[NSURL URLWithString:[dc objectForKey:@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
        img.layer.cornerRadius=28;
        img.layer.masksToBounds=YES;
        [cell addSubview:img];

        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(80, 10, bounds.size.width-100, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:18.0f]];
        [label setText:[dc objectForKey:@"brandName"]];
        [cell addSubview:label];
    
        UILabel* label1=[[UILabel alloc]initWithFrame:CGRectMake(80, 36, bounds.size.width-100, 26)];
        [label1 setTextColor:[UIColor whiteColor]];
        [label1 setFont:[UIFont systemFontOfSize:14.0f]];
        [label1 setText:[dc objectForKey:@"cateName"]];
        [cell addSubview:label1];
        
        if ([dic objectForKey:@"isSale"]) {
            UIImageView* card1=[[UIImageView alloc]initWithFrame:CGRectMake(bounds.size.width-100, 40, 24, 18)];
            [card1 setImage:[UIImage imageNamed:@"ic_sale_card"]];
            [cell addSubview:card1];
        }
        if ([dic objectForKey:@"isMember"]) {
            UIImageView* card2=[[UIImageView alloc]initWithFrame:CGRectMake(bounds.size.width-65, 40, 24, 18)];
            [card2 setImage:[UIImage imageNamed:@"ic_member_card"]];
            [cell addSubview:card2];
        }

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
    NSDictionary * dic=[datas objectAtIndex:indexPath.section];
    if (dic) {
        NSArray* array=(NSArray*)[dic objectForKey:@"cates"];
        int idx=indexPath.row;
        NSDictionary* dc=[array objectAtIndex:idx>[array count]?0:idx];

        BrandViewController* dController=[[BrandViewController alloc]init];
        dController.infoDict=dc;
        [self.navigationController pushViewController:dController animated:YES];
    }
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
