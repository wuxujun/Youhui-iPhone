//
//  BrandViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BrandViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "BrandTViewController.h"
#import "WebViewController.h"
#import "BrandFootView.h"
#import "UIView+LoadingView.h"
#import "UMSocial.h"
#import "CollectEntity.h"
#import "SIAlertView.h"
#import "HCurrentUserContext.h"
#import "BCommentViewController.h"

@interface BrandViewController()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,YSearchDisplayDelegate,BrandHeadViewDelegate,BrandFootViewDelegate,UIAlertViewDelegate,UMSocialUIDelegate>
{
    int         brandId;
    int         mallId;
    
    NSString                *tel;
    BrandHeadView*          headView;

    BrandFootView*          footView;
    
}
@property (nonatomic,strong) YSearchDisplayController*    ySearchDisplayController;

@end

@implementation BrandViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addBackBarButton];
    datas=[[NSMutableArray alloc]init];
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchScan"] style:UIBarButtonItemStylePlain target:self action:@selector(openCamera:)];
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50) style:UITableViewStyleGrouped];
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
    
    if (footView==nil) {
        footView=[[BrandFootView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20-49, self.view.frame.size.width,49) delegate:self];
        
    }
    [self.view addSubview:footView];
//    [mTableView setTableFooterView:footView];
    
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
        CollectEntity* entity=[CollectEntity MR_findFirstByAttribute:@"bid" withValue:[NSNumber numberWithInt:brandId]];
        if (entity!=nil) {
            [footView isCollect:YES];
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
    [self removeCenterSearchBar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertRequestResult:(NSString *)msg isPop:(BOOL)flag
{
    SIAlertView * aView=[[SIAlertView alloc]initWithTitle:nil andMessage:msg];
    [aView addButtonWithTitle:@"关闭" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
        if (flag) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    [aView show];
    double delayInSeconds=2.0;
    dispatch_time_t popTime=dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
    dispatch_after(popTime,dispatch_get_main_queue(),^(void){
        [aView dismissAnimated:YES];
        if (flag) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    });
}


-(void)requestData
{
    NSString *url = [NSString stringWithFormat:@"%@brandD",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",mallId],@"mallId",[NSString stringWithFormat:@"%d",brandId],@"brandId", nil]];
    [self.view showHUDLoadingView:YES];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        DLog(@"%@",result);
        NSDictionary* rs=(NSDictionary*)result;
        id  dc=[rs objectForKey:@"brandInfo"];
        if ([dc isKindOfClass:[NSDictionary class]]) {
            [headView setDict:dc];
            if ([dc objectForKey:@"tel"]) {
                tel=[NSString stringWithFormat:@"%@",[dc objectForKey:@"tel"]];
            }
            [titleLabel setText:[dc objectForKey:@"brandName"]];
        }
        NSArray * arr=[rs objectForKey:@"saleInfo"];
        if ([arr count]>0) {
            NSDictionary* d=[arr objectAtIndex:0];
            [datas addObject:[NSString stringWithFormat:@"%@",[d objectForKey:@"title"]]];
            [datas addObject:[NSString stringWithFormat:@"%@ %@",[d objectForKey:@"startTime"],[d objectForKey:@"endTime"]]];
            [datas addObject:[NSString stringWithFormat:@"%@",[d objectForKey:@"address"]]];
            [datas addObject:[NSString stringWithFormat:@"%@",[d objectForKey:@"remark"]]];
        }else{
            [datas addObject:@"暂无优惠活动."];
        }
        [mTableView reloadData];
        [self.view showHUDLoadingView:NO];
    } error:^(NSError *error) {
        DLog(@"get home fail");
    }];
}

-(CGFloat)cellHeight:(NSString*)text{
    UILabel *lable=[[UILabel alloc]init];
    lable.text=text;
    lable.numberOfLines = 10;
    CGSize size = CGSizeMake(self.view.frame.size.width-20, 1000);
    CGSize labelSize = [lable.text sizeWithFont:lable.font constrainedToSize:size lineBreakMode:NSLineBreakByClipping];
    lable.frame = CGRectMake(lable.frame.origin.x, lable.frame.origin.y, labelSize.width, labelSize.height);
    
    return labelSize.height+10;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
    }
    return [datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 48;
       default:
        {
            return [self cellHeight:[datas objectAtIndex:indexPath.row]];
        }
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    CGRect bounds=self.view.frame;
    switch (indexPath.section) {
        case 0:
        {
            NSArray* titles=@[@"精品推荐",@"网友点评"];
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(10, (48-26)/2, 200, 26)];
            [label setText:titles[indexPath.row]];
            
            [label setTextColor:[UIColor whiteColor]];
            [cell addSubview:label];
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 47, bounds.size.width, 1)];
            [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
            [cell addSubview:line];
        }
            break;
        default:
        {
            float h=[self cellHeight:[datas objectAtIndex:indexPath.row]];
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, bounds.size.width-20, h)];
            [label setText:[datas objectAtIndex:indexPath.row]];
            [label setTextColor:[UIColor whiteColor]];
            [cell addSubview:label];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row==0) {
                BrandTViewController* dController=[[BrandTViewController alloc]init];
                dController.infoDict=self.infoDict;
                [self.navigationController pushViewController:dController animated:YES];
            }else if(indexPath.row==1){
                BCommentViewController* dController=[[BCommentViewController alloc]init];
                dController.infoDict=self.infoDict;
                [self.navigationController pushViewController:dController animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)onBrandFootViewClicked:(int)type
{
    switch (type) {
        case 0:
        {
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"54f14debfd98c5361e000979"
                                              shareText:@"友盟社会化分享让您快速实现分享等社会化功能，http://umeng.com/social"
                                             shareImage:[UIImage imageNamed:@"icon"]
                                        shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSms,UMShareToEmail,nil]
                                               delegate:self];
            break;
        }
        case 1:{
            if (tel) {
                UIAlertView* aView=[[UIAlertView alloc]initWithTitle:nil message:@"确认呼叫吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [aView show];
            }else{
                UIAlertView * aView=[[UIAlertView alloc]initWithTitle:@"暂无联系电话" message:nil delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
                [aView show];
            }
            break;
        }
        case 2:{
            
            DLog(@"%@",self.infoDict);
            if ([[HCurrentUserContext sharedInstance] uid]) {
                CollectEntity* entity=[CollectEntity MR_findFirstByAttribute:@"bid" withValue:[NSNumber numberWithInt:[[self.infoDict objectForKey:@"brandId"] intValue]]];
                if (entity!=nil) {
                    [entity MR_deleteEntity];
                    [self alertRequestResult:@"取消收藏成功" isPop:NO];
                    [footView isCollect:NO];
                }else{
                    
                    CollectEntity *entity=[CollectEntity MR_createEntity];
                    [entity setTitle:[self.infoDict objectForKey:@"brandName"]];
                    [entity setImage:[self.infoDict objectForKey:@"brandLogo"]];
                    [entity setBid:[NSNumber numberWithInt:[[self.infoDict objectForKey:@"brandId"] intValue]]];
                    [entity setMid:[NSNumber numberWithInt:[[self.infoDict objectForKey:@"mallId"] intValue]]];
                    [entity setImage:[self.infoDict objectForKey:@"brandLogo"]];
                    
                    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                        if (contextDidSave) {
                            DLog(@"%d",contextDidSave);
                            [self alertRequestResult:@"收藏成功" isPop:NO];
                            [footView isCollect:YES];
                        }
                    }];
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_OpenLogin" object:nil userInfo:nil];
            }
            
            break;
        }
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
         DLog(@"%@",self.infoDict);
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[NSString stringWithFormat:@"tel:%@",tel]]];
        }else{
            UIAlertView * aView=[[UIAlertView alloc]initWithTitle:@"设备不支持拨打电话." message:nil delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
            [aView show];
        }
    }
}

-(void)onBrandHeadViewClicked:(BrandHeadView *)view
{
    
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    DLog(@"%d",response.responseCode);
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    DLog(@"%@",platformName);
}

@end
