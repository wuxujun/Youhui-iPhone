//
//  MallViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MallViewController.h"
#import "HPageControl.h"
#import "UIViewController+NavigationBarButton.h"
#import "MallHeadView.h"
#import "BannerView.h"
#import "YSearchDisplayController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
#import "MallPagesViewController.h"
#import "BrandViewController.h"
#import "UIView+LoadingView.h"
#import "MallPagesViewController.h"
#import "AMapViewController.h"

@interface MallViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,YSearchDisplayDelegate,MallHeadViewDelegate>
{
    UIView              *mHeadView;
    UIScrollView        *mSrollView;
    HPageControl        *mPageControl;
    
    
    int                 mallId;
    
    int                 brandSale;
    int                 brandCount;
}

@property (nonatomic,strong) YSearchDisplayController*    ySearchDisplayController;

@end

@implementation MallViewController

#define SEARCH_VIEW_TAG  1001
-(void)goSearch
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    YSearchDisplayController *searchDisplayVC = [[YSearchDisplayController alloc] initWithSearchContentType:YContentTypeHome];
    searchDisplayVC.delegate = self;
    searchDisplayVC.searchResultsDataDelagate = self;
    searchDisplayVC.searchResultsDataSource = self;
    searchDisplayVC.view.frame = self.view.frame;
    searchDisplayVC.view.tag = SEARCH_VIEW_TAG;
    self.ySearchDisplayController = searchDisplayVC;
    [self.ySearchDisplayController.searchBar setPlacehoder:@"请输入关键字"];
    [self.view addSubview:searchDisplayVC.view];
    [self addChildViewController:searchDisplayVC];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addBackBarButton];
    
    datas=[[NSMutableArray alloc]init];
    
    UIButton *rightBtn=[[UIButton alloc]init];
    [rightBtn setFrame:CGRectMake(0, 0,30, 30)];
    [rightBtn setImage:[UIImage imageNamed:@"ic_loc"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(openMap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:mTableView];
    }
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    if (self.infoDict) {
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:[self.infoDict objectForKey:@"mallName"]];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
        
        mallId=[[self.infoDict objectForKey:@"mid"] intValue];
    }
    [self initHeader];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)openMap:(id)sender
{
    AMapViewController* dController=[[AMapViewController alloc]init];
    [self.navigationController pushViewController:dController animated:YES];
    
}
-(void)requestData
{
    NSString *url = [NSString stringWithFormat:@"%@mallBrand",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",mallId],@"mallId", nil]];
    [self.view showHUDLoadingView:YES];
    __weak MallViewController* myself=self;
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
//        DLog(@"%@",result);
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

-(void)initHeader
{
    if (mHeadView==nil) {
        mHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 160.0)];
        [mTableView setTableHeaderView:mHeadView];
    }
    
    if (mSrollView==nil) {
        mSrollView=[[UIScrollView alloc]initWithFrame:mHeadView.frame];
        mSrollView.pagingEnabled=YES;
        mSrollView.backgroundColor=TABLE_BACKGROUND_COLOR;
        mSrollView.delegate=self;
        mSrollView.showsHorizontalScrollIndicator=NO;
        mSrollView.showsVerticalScrollIndicator=NO;
        [mHeadView addSubview:mSrollView];
    }
    
    if (mPageControl==nil) {
        mPageControl=[[HPageControl alloc]initWithFrame:CGRectMake(0, mHeadView.frame.size.height-20, mHeadView.frame.size.width, 20)];
        [mHeadView addSubview:mPageControl];
    }
    
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
    
    NSArray* imgs=[self.infoDict objectForKey:@"images"];
    NSInteger count=[imgs count];
    BannerView *item;
    if (count==0) {
        item=[[BannerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, mSrollView.frame.size.height) delegate:self];
        [item setDict:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[self.infoDict objectForKey:@"image"]],@"image", nil]];
        [mSrollView addSubview:item];

    }else{
        for (int i=0; i<[imgs count]; i++) {
            NSDictionary *dc=[imgs objectAtIndex:i];
            item=[[BannerView alloc]initWithFrame:CGRectMake(i*self.view.frame.size.width, 0, self.view.frame.size.width, mSrollView.frame.size.height) delegate:self];
            [item setDict:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[dc objectForKey:@"image"]],@"image", nil]];
            [mSrollView addSubview:item];
        }
    }
    mPageControl.currentPage=0;
    mSrollView.contentSize=CGSizeMake(mSrollView.frame.size.width*count, mSrollView.frame.size.height);
    mPageControl.numberOfPages=count;
    [mSrollView bringSubviewToFront:mPageControl];
}

-(void)runTimePage
{
    NSInteger page=mPageControl.currentPage;
    page++;
    page=page>6?0:page;
    mPageControl.currentPage=page;
    [self turnPage];
}

-(void)turnPage
{
    NSInteger page=mPageControl.currentPage;
    [mSrollView scrollRectToVisible:CGRectMake(320*(page+1), 0, mSrollView.frame.size.width, mSrollView.frame.size.height) animated:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat  pageWidth=mSrollView.frame.size.width;
    int page=floor((mSrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    page--;
    mPageControl.currentPage=page;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    CGFloat  pageWidth=mSrollView.frame.size.width;
//    int page=floor((mSrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
//    if (page==0) {
//        [mSrollView scrollRectToVisible:CGRectMake(320*7, 0, mSrollView.frame.size.width, mSrollView.frame.size.height) animated:NO];
//    }else if(page==7){
//        [mSrollView scrollRectToVisible:CGRectMake(320, 0, mSrollView.frame.size.width, mSrollView.frame.size.height) animated:NO];
//    }
//    DLog(@"%d",page);
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return [datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 60;
        default:
        {
//            NSDictionary* dic=[datas objectAtIndex:indexPath.row-1];
//            if ([[dic objectForKey:@"type"] intValue]==1) {
//                return 118;
//            }
            return 64;
        }
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect bounds=self.view.frame;
    if (section==1) {
        UIView* view=[[UIView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,32)];
        view.backgroundColor=TABLE_HEAD_BACKGROUND_COLOR;
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20,(32-26)/2, 200, 26)];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:14.0f]];
        [label setText:@"折扣品牌"];
        [view addSubview:label];
        
        return view;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }
    return 32.0;
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
            MallHeadView* head=[[MallHeadView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, 60) delegate:self];
            [cell addSubview:head];
            
//            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20, (44-26)/2, 200, 26)];
//            [label setText:@"优惠及品牌分布"];
//            [label setTextColor:[UIColor whiteColor]];
//            [cell addSubview:label];
            UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 59, bounds.size.width, 1)];
            [line setBackgroundColor:TABLE_BACKGROUND_COLOR];
            [cell addSubview:line];
            
//            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
            break;
        default:
        {
            NSDictionary* dic=[datas objectAtIndex:indexPath.row];
//            if ([[dic objectForKey:@"type"] intValue]==1) {
//                UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, 118)];
//                [img setContentMode:UIViewContentModeScaleToFill];
//                [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_cell_normal"]];
//                [cell addSubview:img];
//                
//                UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20, (118-26)/2, bounds.size.width/2, 26)];
//                [label setTextColor:[UIColor whiteColor]];
//                [label setTextAlignment:NSTextAlignmentLeft];
//                [label setFont:[UIFont systemFontOfSize:18.0f]];
//                [label setText:[dic objectForKey:@"title"]];
//                [cell addSubview:label];
//                
//            }else{
            
                UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 54, 54)];
                [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"brandLogo"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
                img.layer.cornerRadius=28;
                img.layer.masksToBounds=YES;
                [cell addSubview:img];
            
                UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(70, 8, bounds.size.width-100, 26)];
                [label setTextColor:[UIColor whiteColor]];
                [label setFont:[UIFont systemFontOfSize:18.0f]];
                [label setText:[dic objectForKey:@"brandName"]];
                [cell addSubview:label];
            
                UILabel* desc=[[UILabel alloc]initWithFrame:CGRectMake(70, 36, bounds.size.width-100, 26)];
                [desc setTextColor:[UIColor whiteColor]];
                [desc setFont:[UIFont systemFontOfSize:12.0f]];
                [desc setText:[dic objectForKey:@"title"]];
                [cell addSubview:desc];
                
                int x=bounds.size.width-110;
                int count=0;
                if ([[dic objectForKey:@"tag0"] isEqual:@"1"]&&count<3) {
                    UIImageView* card1=[[UIImageView alloc]initWithFrame:CGRectMake(x, (64-18)/2, 24, 18)];
                    [card1 setImage:[UIImage imageNamed:@"ic_tag_0"]];
                    [cell addSubview:card1];
                    count++;
                }
            
                if ([[dic objectForKey:@"tag1"] isEqual:@"1"]&&count<3) {
                    UIImageView* card2=[[UIImageView alloc]initWithFrame:CGRectMake(x+count*26, (64-18)/2, 24, 18)];
                    [card2 setImage:[UIImage imageNamed:@"ic_tag_1"]];
                    [cell addSubview:card2];
                    count++;
                }
                if ([[dic objectForKey:@"tag2"] isEqual:@"1"]&&count<3) {
                    UIImageView* card2=[[UIImageView alloc]initWithFrame:CGRectMake(x+count*26, (64-18)/2, 24, 18)];
                    [card2 setImage:[UIImage imageNamed:@"ic_tag_2"]];
                    [cell addSubview:card2];
                    count++;
                }
                if ([[dic objectForKey:@"tag3"] isEqual:@"1"]&&count<3) {
                    UIImageView* card2=[[UIImageView alloc]initWithFrame:CGRectMake(x+count*26, (64-18)/2, 24, 18)];
                    [card2 setImage:[UIImage imageNamed:@"ic_tag_3"]];
                    [cell addSubview:card2];
                    count++;
                }
                if ([[dic objectForKey:@"tag4"] isEqual:@"1"]&&count<3) {
                    UIImageView* card2=[[UIImageView alloc]initWithFrame:CGRectMake(x+count*26, (64-18)/2, 24, 18)];
                    [card2 setImage:[UIImage imageNamed:@"ic_tag_4"]];
                    [cell addSubview:card2];
                    count++;
                }
                if ([[dic objectForKey:@"tag5"] isEqual:@"1"]&&count<3) {
                    UIImageView* card2=[[UIImageView alloc]initWithFrame:CGRectMake(x+count*26, (64-18)/2, 24, 18)];
                    [card2 setImage:[UIImage imageNamed:@"ic_tag_5"]];
                    [cell addSubview:card2];
                    count++;
                }
                if ([[dic objectForKey:@"tag6"] isEqual:@"1"]&&count<3) {
                    UIImageView* card2=[[UIImageView alloc]initWithFrame:CGRectMake(x+count*26, (64-18)/2, 24, 18)];
                    [card2 setImage:[UIImage imageNamed:@"ic_tag_6"]];
                    [cell addSubview:card2];
                    count++;
                }
            
                UIView* line=[[UIView alloc]initWithFrame:CGRectMake(70, 63, bounds.size.width, 1)];
                [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
                [cell addSubview:line];
                cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
//            }
        }
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        MallPagesViewController* dController=[[MallPagesViewController alloc]  init];
        dController.infoDict=self.infoDict;
        [self.navigationController pushViewController:dController animated:YES];
    }else{
        NSDictionary* dic=[datas objectAtIndex:indexPath.row];
//        DLog(@"%@",dic);
//        if ([[dic objectForKey:@"type"] intValue]==0) {
            BrandViewController* dController=[[BrandViewController alloc]init];
            dController.infoDict=dic;
            [self.navigationController pushViewController:dController animated:YES];
//        }
    }
}

#pragma mark - YSearchDisplayControllerDelegate
- (void)ySearchDisplayControllerDidEndSearch:(YSearchDisplayController *)controller
{
    UIView *searchView = [self.view viewWithTag:SEARCH_VIEW_TAG];
    [searchView removeFromSuperview];
    //    self.searchResults = nil;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)ySearchDisplayController:(YSearchDisplayController *)controller searchString:(NSString *)searchString
{
    //    self.searchResults = [[[DXYDBManager sharedInstance] searchCategoryWithType:GUIDE_CATEGORY target:searchString] mutableCopy];
    [controller.searchResultsTableView reloadData];
    
    //    [controller showLogoView:NO];
    //    if (self.searchResults.count == 0) {
    //        controller.searchResultsTableView.tableFooterView = self.noResultView;
    //    }else{
    //        controller.searchResultsTableView.tableFooterView = nil;
    //    }
}

-(void)onMallHeadViewClicked:(int)type
{
    MallPagesViewController* dController=[[MallPagesViewController alloc] init];
    dController.infoDict=self.infoDict;
    dController.tabIndex=type;
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}
@end
