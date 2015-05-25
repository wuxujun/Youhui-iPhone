//
//  MapViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MapViewController.h"
#import "MItemView.h"
#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"
#import "MallPagesViewController.h"
#import "SearchViewController.h"
#import "SearchHeadView.h"
#import "UIView+LoadingView.h"


@interface MapViewController()<UITableViewDataSource,UITableViewDelegate,MItemViewDelegate,YSearchDisplayDelegate,SearchHeadViewDelegate>
{
    UIBarButtonItem     *cityButton;
}
@property (nonatomic,strong) YSearchDisplayController*    ySearchDisplayController;
@property (nonatomic,assign) BOOL                         isSearching;
@end

@implementation MapViewController


-(id)init
{
    self=[super init];
    if (self) {
        self.title=@"地图";
        self.navigationItem.title=@"";
        
        [self.tabBarItem setImage:[UIImage imageNamed:@"Map"]];
        [self.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        
    }
    return self;
}

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
    self.isSearching=YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    datas=[[NSMutableArray alloc]init];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_message"] style:UIBarButtonItemStylePlain target:self action:@selector(openMessage:)];
    
    cityButton=[[UIBarButtonItem alloc]initWithTitle:@"杭州" style:UIBarButtonItemStylePlain target:self action:@selector(citySelect:)];
    [cityButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:cityButton, nil];
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    cellHeight=(self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-20)/4;
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        [self.view addSubview:mTableView];
    }
    [self loadData];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCenterSearchBar:@selector(goSearch)];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeCenterSearchBar];
}

-(void)loadData
{
    NSString *url = [NSString stringWithFormat:@"%@maps",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"571",@"city", nil]];
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        [datas addObjectsFromArray:arr];
        [mTableView reloadData];
    } error:^(NSError *error) {
        DLog(@"get home fail");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching) {
        return 1;
    }
    return [datas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching) {
        return 160.0;
    }
    
//    switch (indexPath.row) {
//        case 2:
//            return 264;
//        default:
//            return 152;
//    }
    return cellHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    CGRect bounds=self.view.frame;
    if (self.isSearching) {
        SearchHeadView*  searchHeadView=[[SearchHeadView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 160) delegate:self];
        [cell addSubview:searchHeadView];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    
    }else{
//        switch (indexPath.row) {
//            case 2:
//            {
//                NSDictionary* dic=[datas objectAtIndex:indexPath.row];
//                NSInteger idx=indexPath.row;
//                MItemView* item=[[MItemView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width*0.6, 132) delegate:self];
//                [item setDict:dic];
//                [cell addSubview:item];
//                if ((indexPath.row+1)<[datas count]) {
//                    MItemView* item1=[[MItemView alloc]initWithFrame:CGRectMake(0, 132, bounds.size.width*0.6, 132) delegate:self];
//                    [item1 setDict:[datas objectAtIndex:indexPath.row+1]];
//                    [cell addSubview:item1];
//                }
//                if ((indexPath.row+2)<[datas count]) {
//                    MItemView* item2=[[MItemView alloc]initWithFrame:CGRectMake(bounds.size.width*0.6, 0, bounds.size.width*0.4, 265) delegate:self];
//                    [item2 setDict:[datas objectAtIndex:indexPath.row+2]];
//                    [cell addSubview:item2];
//                }
//            
//            }
//                break;
//            case 0:
//            case 1:
//            {
                NSDictionary* dic=[datas objectAtIndex:indexPath.row];
                MItemView* item=[[MItemView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, cellHeight-1) delegate:self];
                [item setDict:dic];
                [cell addSubview:item];
//            
//            }
//                break;
//            default:
//            {
//                if ((indexPath.row+3)<[datas count]) {
//                    MItemView* item=[[MItemView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, 152) delegate:self];
//                    [item setDict:[datas objectAtIndex:indexPath.row+3]];
//                    [cell addSubview:item];
//                }
//            }
//                break;
//        }
        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, cellHeight-1, bounds.size.width, 1)];
        [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
        [cell addSubview:line];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching) {
        
    }
}

-(void)onMItemViewClicked:(MItemView *)view
{
    MallPagesViewController* dController=[[MallPagesViewController alloc] init];
    dController.infoDict=view.dict;
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

#pragma mark - YSearchDisplayControllerDelegate
- (void)ySearchDisplayControllerDidEndSearch:(YSearchDisplayController *)controller
{
    UIView *searchView = [self.view viewWithTag:SEARCH_VIEW_TAG];
    [searchView removeFromSuperview];
    //    self.searchResults = nil;
    self.isSearching=NO;
    [mTableView reloadData];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)ySearchDisplayController:(YSearchDisplayController *)controller searchString:(NSString *)searchString
{
    //    self.searchResults = [[[DXYDBManager sharedInstance] searchCategoryWithType:GUIDE_CATEGORY target:searchString] mutableCopy];
//    [controller.searchResultsTableView reloadData];
    
    //    [controller showLogoView:NO];
    //    if (self.searchResults.count == 0) {
    //        controller.searchResultsTableView.tableFooterView = self.noResultView;
    //    }else{
    //        controller.searchResultsTableView.tableFooterView = nil;
    //    }
    
    [self search:searchString];
}

-(void)search:(NSString*)searchKey
{
    UIView *searchView = [self.view viewWithTag:SEARCH_VIEW_TAG];
    [searchView removeFromSuperview];
//    [mTableView setTableHeaderView:mHeadView];
//    [self loadHomeData];
    self.isSearching=NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    SearchViewController* dController=[[SearchViewController alloc]init];
    dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:searchKey,@"searchKey",[NSString stringWithFormat:@"%@",searchKey],@"title", @"2",@"searchType",nil];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

-(void)onSearchHeadButtonClick:(NSString *)searchKey
{
    [self search:searchKey];
}

@end
