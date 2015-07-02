//
//  HomeViewController.m
//  Youhui
//
//  Created by xujunwu on 15/1/29.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "HomeViewController.h"
#import <Accelerate/Accelerate.h>
#import "CRNavigationBar.h"
#import "CRNavigationController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+NavigationBarButton.h"
#import "BannerView.h"
#import "YSearchDisplayController.h"
#import "MallViewController.h"
#import "BrandViewController.h"
#import "WebViewController.h"
#import "HNetworkEngine.h"
#import "UserDefaultHelper.h"
#import "UIImageView+AFNetworking.h"
#import "PagedFlowView.h"
#import "HItemView.h"
#import "SHistoryEntity.h"
#import "SearchHeadView.h"
#import "HBlurView.h"
#import "SearchViewController.h"
#import "UIView+LoadingView.h"
#import "AppDelegate.h"
#import "HImageCache.h"
#import "UIImage+Custome.h"


@interface HomeViewController ()<PagedFlowViewDataSource,PagedFlowViewDelegate,HItemViewDelegate,SearchHeadViewDelegate,YSearchDisplayDelegate,BannerViewDelegate,AMapSearchDelegate>
{
    CLLocationManager   *locManager;
    AMapSearchAPI       *_search;
    
    NSString            *currentCityName;
    NSString            *currentCityCode;
    
    UIView              *mHeadView;
    UIScrollView        *mSrollView;
    HPageControl        *mPageControl;
    UIView              *boxblurView;
    
    UIBarButtonItem*        cityButton;
    
    NSMutableArray      *headDatas;
    NSMutableArray      *homeDatas;
    NSMutableArray      *searchKeyDatas;
    
    PagedFlowView       *coverFlowView;
    UIPageControl       *coverPageControl;
    UIImageView         *mallLogo;
    UIImageView         *titleBG;
    UILabel             *titleLabel;
    
    float               headHeight;
}

@property (nonatomic,strong) YSearchDisplayController*    ySearchDisplayController;
@property (nonatomic,assign) BOOL       isSearching;

@property (nonatomic,strong)UILabel             *cityLabel;
@property (nonatomic,strong)UIImageView         *weatherIcon;
@property (nonatomic,strong)UILabel             *weatherLabel;

@property (nonatomic,strong)NSMutableDictionary     *cachedImages;

@end

@implementation HomeViewController

-(id)init
{
    self=[super init];
    if (self) {
        self.title=@"主页";
        self.navigationItem.title=@"";
        [self.tabBarItem setImage:[UIImage imageNamed:@"Home"]];
//        self.tabBarItem.selectedImage=[UIImage imageNamed:@"Home_Press"];
//        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
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
    [self loadHistoryKey];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    currentCityCode=[UserDefaultHelper objectForKey:CURRENT_CITY_CODE];
    currentCityName=[UserDefaultHelper objectForKey:CURRENT_CITY_TITLE];
    homeDatas=[[NSMutableArray alloc]init];
    headDatas=[[NSMutableArray alloc]init];
    searchKeyDatas=[[NSMutableArray alloc]init];
    self.cachedImages=[@{} mutableCopy];
    
    
    if ([CLLocationManager locationServicesEnabled]) {
        locManager=[[CLLocationManager alloc]init];
        locManager.delegate=self;
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=1000;
        if (IOS_VERSION_8) {
//            [locManager requestAlwaysAuthorization];
            [locManager requestWhenInUseAuthorization];
        }
    }
    _search=[[AMapSearchAPI alloc]initWithSearchKey:AMPAP_KEY Delegate:self];
    CGFloat w=[self.navigationItem.rightBarButtonItem width];
    CGFloat h=self.navigationController.navigationBar.frame.size.height;
    
    UIButton *rightBtn=[[UIButton alloc]init];
    [rightBtn setFrame:CGRectMake(0, 0,30, 30)];
    [rightBtn setImage:[UIImage imageNamed:@"ic_message"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"ic_message_on"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(openMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    if (self.cityLabel==nil) {
        self.cityLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 26)];
        [self.cityLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.cityLabel setTextColor:[UIColor whiteColor]];
        [self.cityLabel setTextAlignment:NSTextAlignmentCenter];
        [self.cityLabel setText:@"杭州"];
    }
    
    if (self.weatherIcon==nil) {
        self.weatherIcon=[[UIImageView alloc]initWithFrame:CGRectMake(1, 26, 14, 14)];
    }
    
    if (self.weatherLabel==nil) {
        self.weatherLabel=[[UILabel alloc]initWithFrame:CGRectMake(16, 26, 40, 16)];
        [self.weatherLabel setFont:[UIFont systemFontOfSize:9.0]];
        [self.weatherLabel setTextColor:[UIColor whiteColor]];
    }
    
    UIButton *leftView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    [leftView addTarget:self action:@selector(citySelect:) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:self.cityLabel];
    [leftView addSubview:self.weatherIcon];
    [leftView addSubview:self.weatherLabel];
    cityButton=[[UIBarButtonItem alloc]  initWithCustomView:leftView];
//    cityButton=[[UIBarButtonItem alloc]initWithTitle:@"杭州" style:UIBarButtonItemStylePlain target:self action:@selector(citySelect:)];
//    [cityButton setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:cityButton, nil];
    
    self.networkEngine=[[HNetworkEngine alloc]initWithHostName:nil customHeaderFields:nil];
    
    int count=4;
    DLog(@"%f",self.view.frame.size.height);
    if (self.view.frame.size.height>667) {
        count=5;
    }
    float cellH=(self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-20)/count;
    headHeight=cellH*2;
    cellHeight=(cellH*2)/1.5;
    if (self.view.frame.size.height>667) {
        cellHeight=cellH*3/2;
    }
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=self;
        mTableView.dataSource=self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.rowHeight=cellHeight;
        mTableView.backgroundColor=RGBCOLOR(30, 33, 38);
        [self.view addSubview:mTableView];
    }

    [self loadWeather];
    [self initHeader];
    [self loadHomeData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addCenterSearchBar:@selector(goSearch)];
    [locManager startUpdatingLocation];
    
    NSString* cityCode;
    NSString* cityName;
    if ([UserDefaultHelper objectForKey:CURRENT_CITY_CODE]) {
        cityCode=[UserDefaultHelper objectForKey:CURRENT_CITY_CODE];
    }
    if ([UserDefaultHelper objectForKey:CURRENT_CITY_TITLE]) {
        cityName=[UserDefaultHelper objectForKey:CURRENT_CITY_TITLE];
        [self.cityLabel setText:cityName];
    }
    if ([cityCode isEqual:currentCityCode]) {
        
    }else{
        currentCityCode=cityCode;
        currentCityName=cityName;
        [homeDatas removeAllObjects];
//        [headDatas removeAllObjects];
        [self loadHomeData];
    }
//    [[ApplicationDelegate tabViewController] hidenTabbarView:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [locManager stopUpdatingLocation];
    [self removeCenterSearchBar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadHistoryKey
{
    [searchKeyDatas removeAllObjects];
    NSArray * hiss=[SHistoryEntity MR_findAllSortedBy:@"hid" ascending:YES];
    [searchKeyDatas addObjectsFromArray:hiss];
   
    [mTableView reloadData];
}

-(void)loadWeather
{
    NSString *url = @"http://api.mchome.cn/w.php";
    [self.networkEngine getOperationWithURLString:url params:nil success:^(MKNetworkOperation *completedOperation, id result) {
//        DLog(@"%@",result);
        NSDictionary* dic=[result objectForKey:@"f"];
        NSArray* f=[dic objectForKey:@"f1"];
        if ([f count]>0) {
            NSDictionary *dc=[f objectAtIndex:0];
            [self refreshWeather:dc];
        }
    } error:^(NSError *error) {
        DLog(@"get weather fail");
    }];
    
}

-(void)refreshWeather:(NSDictionary*)dict
{
    NSString* fa=[dict objectForKey:@"fa"];
    if (fa&&![fa isEqualToString:@""]) {
        [self.weatherIcon setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://i.tq121.com.cn/i/mobile/images/n%@.png",[dict objectForKey:@"fa"]]]];
    }else{
        [self.weatherIcon setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://i.tq121.com.cn/i/mobile/images/n%@.png",[dict objectForKey:@"fb"]]]];
    }
    
    NSString* fc=[dict objectForKey:@"fc"];
    if (fc&&![fc isEqualToString:@""]) {
        [self.weatherLabel setText:[NSString stringWithFormat:@"%@~%@℃",fc,[dict objectForKey:@"fd"]]];
    }else{
        [self.weatherLabel setText:[NSString stringWithFormat:@"%@℃",[dict objectForKey:@"fd"]]];
    }
}

-(void)loadHomeData
{
    NSString *url = [NSString stringWithFormat:@"%@home",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:currentCityCode,@"city", nil]];
    [self.view showHUDLoadingView:YES];
    __weak HomeViewController* myself=self;
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
//        DLog(@"%@",result);
        NSDictionary* rs=(NSDictionary*)result;
        [UserDefaultHelper setObject:[rs objectForKey:@"searchKey"] forKey:SEARCH_HOT_KEY];
        NSArray * arr=[rs objectForKey:@"root"];
        [headDatas removeAllObjects];
        [headDatas addObjectsFromArray:arr];
        NSArray* list=[rs objectForKey:@"homeList"];
        [homeDatas removeAllObjects];
        [homeDatas addObjectsFromArray:list];
        [self refresh];
    } error:^(NSError *error) {
        DLog(@"get home fail");
        [myself.view showHUDLoadingView:NO];
    }];
}

-(void)initHeader
{
    
    if (mHeadView==nil) {
        mHeadView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headHeight)];
        [mTableView setTableHeaderView:mHeadView];
    }
//    if (titleBG==nil) {
//        titleBG=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.15, 164, self.view.frame.size.width*0.7, 80)];
//        [titleBG setImage:[UIImage imageNamed:@"ic_home_item_bg"]];
//    }
    if (mallLogo==nil) {
        mallLogo=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-36)/2, headHeight-50, 36, 36)];
    }
    
    if (titleLabel==nil) {
        titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, headHeight-75, self.view.frame.size.width, 30)];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:13]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
    }

    if (coverPageControl==nil) {
        coverPageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, headHeight-20, self.view.frame.size.width, 14)];
        [coverPageControl addTarget:self action:@selector(pageControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    coverFlowView=[[PagedFlowView alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, headHeight-10) ];
    [coverFlowView setBackgroundColor:TABLE_BACKGROUND_COLOR];
    [coverFlowView setDataSource:self];
    [coverFlowView setDelegate:self];
    [coverFlowView setPageControl:coverPageControl];
    [coverFlowView setMinimumPageAlpha:0.2];
    [coverFlowView setMinimumPageScale:0.8];
    [mHeadView addSubview:coverFlowView];
//    [mHeadView addSubview:titleBG];
    [mHeadView addSubview:mallLogo];
    [mHeadView addSubview:titleLabel];
    [mHeadView addSubview:coverPageControl];
}

-(IBAction)pageControlValueDidChange:(id)sender
{
//    UIPageControl* pageControl=sender;
//    [coverFlowView scrollToPage:pageControl.currentPage];
}

-(void)refresh
{
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
//    BannerView *item;
//    for (int i=0; i<[headDatas count]; i++) {
//        NSDictionary* dic=[headDatas objectAtIndex:i];
//        item=[[BannerView alloc]initWithFrame:CGRectMake(i*self.view.frame.size.width, 0, self.view.frame.size.width, mSrollView.frame.size.height) delegate:self];
//        [item setDict:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"image"],@"image", nil]];
//        [mSrollView addSubview:item];
//    }
//    mPageControl.currentPage=0;
//    mSrollView.contentSize=CGSizeMake(mSrollView.frame.size.width*[headDatas count], mSrollView.frame.size.height);
//    mPageControl.numberOfPages=[headDatas count];
//    [mSrollView bringSubviewToFront:mPageControl];
    [self.view showHUDLoadingView:NO];
    NSDictionary *dic=[headDatas objectAtIndex:0];
    if (dic) {
        [titleLabel setText:[dic objectForKey:@"mallName"]];
        if ([dic objectForKey:@"mallLogo"]) {
            [mallLogo setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"mallLogo"]]];
        }
    }
    [coverFlowView reloadData];
    [mTableView reloadData];
}

-(void)runTimePage
{
    NSInteger page=mPageControl.currentPage;
    page++;
    page=page>([headDatas count]-1)?0:page;
    mPageControl.currentPage=page;
    [self turnPage];
}

-(void)turnPage
{
    NSInteger page=mPageControl.currentPage;
    [mSrollView scrollRectToVisible:CGRectMake(320*(page+1), 0, mSrollView.frame.size.width, mSrollView.frame.size.height) animated:NO];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus---%u",status);
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didChangeAuthorizationStatus----%@",error);
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSString * latitude=[[NSString alloc] initWithFormat:@"%g",newLocation.coordinate.latitude];
    NSString * longitude=[[NSString alloc] initWithFormat:@"%g",newLocation.coordinate.longitude];
//    DLog(@"%@  %@",latitude,longitude);
    [[NSUserDefaults standardUserDefaults] setObject:latitude forKey:GPS_LATITUDE];
    [[NSUserDefaults standardUserDefaults] setObject:longitude forKey:GPS_LONGITUDE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([UserDefaultHelper objectForKey:@"uuid"]) {
        NSString *url = [NSString stringWithFormat:@"%@location",kHttpUrl];
        NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[UserDefaultHelper objectForKey:DEVICE_TOKEN_UUID],@"uuid",latitude,GPS_LATITUDE,longitude,GPS_LONGITUDE, nil]];
        [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
            DLog(@"post location success");
        } error:^(NSError *error) {
            DLog(@"post location fail");
        }];
    }
    
    AMapReGeocodeSearchRequest* request=[[AMapReGeocodeSearchRequest alloc]init];
    request.searchType=AMapSearchType_ReGeocode;
    request.location=[AMapGeoPoint locationWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    request.radius=10000;
    request.requireExtension=YES;
    [_search AMapReGoecodeSearch:request];

}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode!=nil) {
//        DLog(@"%@",response.regeocode);
        if (response.regeocode.addressComponent.city!=nil) {
            currentCityName=response.regeocode.addressComponent.city;
            currentCityCode=response.regeocode.addressComponent.citycode;
        }else{
            currentCityName=response.regeocode.addressComponent.province;
            currentCityCode=response.regeocode.addressComponent.citycode;
        }
        if (currentCityName!=nil) {
            NSRange range=[currentCityName rangeOfString:@"市"];
            if (range.length>0) {
//                DLog(@"%d",NSMaxRange(range));
                currentCityName=[currentCityName substringToIndex:range.location];
            }
            [self.cityLabel setText:currentCityName];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    CGFloat  pageWidth=mSrollView.frame.size.width;
//    int page=floor((mSrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
//    page--;
//    mPageControl.currentPage=page;
    [self.ySearchDisplayController.searchBar cancelEditing];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat  pageWidth=mSrollView.frame.size.width;
    int page=floor((mSrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    if (page==0) {
        [mSrollView scrollRectToVisible:CGRectMake(320*7, 0, mSrollView.frame.size.width, mSrollView.frame.size.height) animated:NO];
    }else if(page==7){
        [mSrollView scrollRectToVisible:CGRectMake(320, 0, mSrollView.frame.size.width, mSrollView.frame.size.height) animated:NO];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isSearching) {
        return 2;
    }
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.isSearching) {
        if (section==0) {
            return 1;
        }
        return [searchKeyDatas count]+1;
    }
    return [homeDatas count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching) {
        if (indexPath.section==0) {
            return 160;
        }
        return 44;
    }
    return cellHeight;
}
//
//-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (self.isSearching) {
//        if (section==0) {
//            return @"热门搜索";
//        }
//        return @"搜索历史";
//    }
//    return nil;
//}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CGRect bounds=self.view.frame;
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    if (self.isSearching) {
        if (indexPath.section==0) {
           SearchHeadView*  searchHeadView=[[SearchHeadView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 160) delegate:self];
            [cell addSubview:searchHeadView];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (indexPath.row==0) {
            cell.backgroundColor=TABLE_BACKGROUND_COLOR;
            
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20, (44-26)/2, 200, 26)];
            [label setText:@"搜索历史"];
            [label setTextColor:[UIColor grayColor]];
            [cell addSubview:label];
            
            UIButton* btn=[[UIButton alloc]initWithFrame:CGRectMake(bounds.size.width-60, 4, 50, 36)];
            [btn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(clearHistory:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
            
        }else{
            SHistoryEntity* entity=[searchKeyDatas objectAtIndex:indexPath.row-1];
            if (entity) {
                cell.textLabel.text=entity.searchKey;
                cell.textLabel.textColor=[UIColor whiteColor];
            }
        }
        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, bounds.size.width, 1)];
        [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
        [cell addSubview:line];
        return cell;
    }else{
        
        NSDictionary* dic=[homeDatas objectAtIndex:indexPath.row];
        HItemView* item=[[HItemView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, cellHeight-1) delegate:self];
        [item setInfoDict:dic];
        [cell addSubview:item];
        
//        UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bounds.size.width, cellHeight-1)];
//        [img setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_cell_normal"]];
//        [cell addSubview:img];
//        
//        UIImageView* bg=[[UIImageView alloc]initWithFrame:CGRectMake(bounds.size.width*0.6,cellHeight-70, bounds.size.width*0.4, 50)];
//        [bg setImage:[[UIImage imageNamed:@"ic_map_title_bg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
//        [cell addSubview:bg];
//        
//        UILabel* lb=[[UILabel alloc]initWithFrame:CGRectMake(bounds.size.width*0.6, cellHeight-70, bounds.size.width*0.4, 30)];
//        [lb setFont:[UIFont boldSystemFontOfSize:18]];
//        [lb setTextColor:[UIColor whiteColor]];
//        [lb setTextAlignment:NSTextAlignmentCenter];
//        [lb setText:[dic objectForKey:@"brandName"]];
//        [cell addSubview:lb];
//        
//        UILabel* lb1=[[UILabel alloc]initWithFrame:CGRectMake(bounds.size.width*0.6, cellHeight-46, bounds.size.width*0.4, 30)];
//        [lb1 setFont:[UIFont systemFontOfSize:16]];
//        [lb1 setTextColor:[UIColor whiteColor]];
//        [lb1 setTextAlignment:NSTextAlignmentCenter];
//        [lb1 setText:[dic objectForKey:@"title"]];
//        [cell addSubview:lb1];
        
        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, cellHeight-1, bounds.size.width, 1)];
        [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
        [cell addSubview:line];

        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.isSearching) {
        if(indexPath.section==1&&indexPath.row>0){
            SHistoryEntity* entity=[searchKeyDatas objectAtIndex:indexPath.row-1];
            if (entity) {
                [self search:entity.searchKey];
            }
        }
    }else{
        
        NSDictionary* dic=[homeDatas objectAtIndex:indexPath.row];
        SearchViewController* dController=[[SearchViewController alloc]init];
        dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"brandName"],@"searchKey",[dic objectForKey:@"brandName"],@"title",@"0",@"searchType",nil];
        dController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:dController animated:YES];
    }
}

-(IBAction)clearHistory:(id)sender
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" 1=1 "];
    [SHistoryEntity MR_deleteAllMatchingPredicate:predicate];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        
    }];
    [self loadHistoryKey];
}

-(void)onHItemViewClicked:(NSDictionary*)aDict
{
//    DLog(@"%@",aDict);
//    WebViewController* dController=[[WebViewController alloc]init];
//    dController.infoDict=aDict;
//    dController.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:dController animated:YES];
    
    SearchViewController* dController=[[SearchViewController alloc]init];
    dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:[aDict objectForKey:@"brandName"],@"searchKey",[aDict objectForKey:@"brandName"],@"title",@"0",@"searchType",nil];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

-(void)onHItemTViewClicked:(NSDictionary *)aDict
{
    
}

-(void)onBannerViewClicked:(BannerView *)view
{
    BrandViewController* dController=[[BrandViewController alloc]init];
    [self.navigationController pushViewController:dController animated:YES];
}

#pragma mark - YSearchDisplayControllerDelegate
- (void)ySearchDisplayControllerDidEndSearch:(YSearchDisplayController *)controller
{
    UIView *searchView = [self.view viewWithTag:SEARCH_VIEW_TAG];
    [searchView removeFromSuperview];
//    self.searchResults = nil;
    [mTableView setTableHeaderView:mHeadView];
    [self loadHomeData];
    self.isSearching=NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)ySearchDisplayController:(YSearchDisplayController *)controller searchString:(NSString *)searchString
{
    DLog(@"%@",searchString);
    SHistoryEntity* entity=[SHistoryEntity MR_createEntity];
    [entity setSearchKey:searchString];
    [entity setHid:[NSNumber numberWithInt:0]];
    [entity setType:[NSNumber numberWithInt:1]];
    [entity setAddTime:[NSDate  date]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        if (contextDidSave) {
            DLog(@"save success");
        }
    }];
    
    [self search:searchString];
    //    self.searchResults = [[[DXYDBManager sharedInstance] searchCategoryWithType:GUIDE_CATEGORY target:searchString] mutableCopy];
//    [controller.searchResultsTableView reloadData];
    
//    [controller showLogoView:NO];
//    if (self.searchResults.count == 0) {
//        controller.searchResultsTableView.tableFooterView = self.noResultView;
//    }else{
//        controller.searchResultsTableView.tableFooterView = nil;
//    }
}


-(CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView
{
    return CGSizeMake(220, 255);
}

-(void)didReloadData:(UIView *)cell cellForPageAtIndex:(NSInteger)index
{
    NSDictionary* dic=[headDatas objectAtIndex:index];
    
    UIImageView *imageView = (UIImageView *)cell;
    [imageView setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
}

-(void)didReloadBlurData:(UIView *)cell cellForPageAtIndex:(NSInteger)index
{
    NSDictionary * dic=[headDatas objectAtIndex:index];
    boxblurView=cell;
    if ([dic objectForKey:@"image"]) {
        NSString* url=[NSString stringWithFormat:@"%@",[dic objectForKey:@"image"]];
        UIImage* image=self.cachedImages[url];
        if (image==nil) {
            __weak HomeViewController* myself=self;
            [[HImageCache sharedInstance] imageWithURL:url withImageSize:cell.frame.size withNetworkEngine:self.networkEngine onCompletion:^(UIImage *fetchedImage, NSString *url) {
                myself.cachedImages[url]=fetchedImage;
                ((UIImageView*)boxblurView).image=[fetchedImage applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.8 maskImage:nil];
                ;
            }];
        }else{
            ((UIImageView*)boxblurView).image=[image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.8 maskImage:nil];
            ;
        }
    }
}

-(void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index
{
//    [coverFlowView showRealTimeBlurWithBlurStyle:HBlurStyleBlackTranslucent];
    NSDictionary* dic=[headDatas objectAtIndex:index];
    [titleLabel setText:[dic objectForKey:@"mallName"]];
    [mallLogo setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"mallLogo"]]];
    
    if ([dic objectForKey:@"image"]&&boxblurView!=nil) {
        NSString* url=[NSString stringWithFormat:@"%@",[dic objectForKey:@"image"]];
        UIImage* image=self.cachedImages[url];
        if (image==nil) {
            __weak HomeViewController* myself=self;
            [[HImageCache sharedInstance] imageWithURL:url withImageSize:boxblurView.frame.size withNetworkEngine:self.networkEngine onCompletion:^(UIImage *fetchedImage, NSString *url) {
                myself.cachedImages[url]=fetchedImage;
                ((UIImageView*)boxblurView).image=[fetchedImage applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.8 maskImage:nil];
            }];
        }else{
            ((UIImageView*)boxblurView).image=[image applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.8 maskImage:nil];
        }
    }
}

-(void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index
{
    DLog(@"%ld",(long)index);
    NSDictionary* dic=[headDatas objectAtIndex:index];
    if (dic) {
        if ([[dic objectForKey:@"bid"] isEqualToString:@"0"]) {
            MallViewController* dController=[[MallViewController alloc]init];
            DLog(@"%@",dic);
            dController.infoDict=dic;
            dController.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:dController animated:YES];
        }else{
            BrandViewController* dController=[[BrandViewController alloc]init];
            dController.infoDict=dic;
            dController.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:dController animated:YES];
        }
    }
}

-(NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView
{
//    DLog(@"%lu",(unsigned long)[headDatas count]);
    return [headDatas count];
}

-(UIView*)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index
{
    NSDictionary* dic=[headDatas objectAtIndex:index];
    UIImageView* imgView=(UIImageView*)[flowView dequeueReusableCell];
    if (!imgView) {
        imgView = [[UIImageView alloc] init];
        imgView.layer.cornerRadius = 2;
        imgView.layer.masksToBounds = YES;
    }
    [imgView sizeToFit];
//    imgView.image = [UIImage imageNamed:[headDatas objectAtIndex:index]];
    [imgView setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"ic_normal"]];
    return imgView;
}


-(void)onSearchHeadButtonClick:(NSString *)searchKey
{
    SHistoryEntity* entity=[SHistoryEntity MR_createEntity];
    [entity setSearchKey:searchKey];
    [entity setHid:[NSNumber numberWithInt:0]];
    [entity setType:[NSNumber numberWithInt:1]];
    [entity setAddTime:[NSDate  date]];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
        if (contextDidSave) {
            DLog(@"save success");
        }
    }];
    [self search:searchKey];
   
}


-(void)search:(NSString*)key
{
    UIView *searchView = [self.view viewWithTag:SEARCH_VIEW_TAG];
    [searchView removeFromSuperview];
    [mTableView setTableHeaderView:mHeadView];
    [self loadHomeData];
    self.isSearching=NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    SearchViewController* dController=[[SearchViewController alloc]init];
    dController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:key,@"searchKey",[NSString stringWithFormat:@"搜索--%@",key],@"title",@"0",@"searchType", nil];
    dController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:dController animated:YES];
}

-(NSString*)getWeatherTitle:(NSString*)val
{
    NSString *result=@"无";
    if ([val isEqualToString:@"00"]) {
        result=@"晴";
    }else if ([val isEqualToString:@"01"]){
        result=@"多云";
    }else if ([val isEqualToString:@"02"]){
        result=@"阴";
    }else if ([val isEqualToString:@"03"]){
        result=@"阵雨";
    }else if ([val isEqualToString:@"04"]){
        result=@"雷阵雨";
    }else if ([val isEqualToString:@"05"]){
        result=@"雷阵雨伴有冰雹";
    }else if ([val isEqualToString:@"06"]){
        result=@"雨夹雪";
    }else if ([val isEqualToString:@"07"]){
        result=@"小雨";
    }else if ([val isEqualToString:@"08"]){
        result=@"中雨";
    }else if ([val isEqualToString:@"09"]){
        result=@"大雨";
    }else if ([val isEqualToString:@"10"]){
        result=@"暴雨";
    }else if ([val isEqualToString:@"11"]){
        result=@"大暴雨";
    }else if ([val isEqualToString:@"12"]){
        result=@"特大暴雨";
    }else if ([val isEqualToString:@"13"]){
        result=@"阵地";
    }else if ([val isEqualToString:@"14"]){
        result=@"小雪";
    }else if ([val isEqualToString:@"15"]){
        result=@"中雪";
    }else if ([val isEqualToString:@"16"]){
        result=@"大雪";
    }else if ([val isEqualToString:@"17"]){
        result=@"暴雪";
    }else if ([val isEqualToString:@"18"]){
        result=@"雾";
    }else if ([val isEqualToString:@"19"]){
        result=@"冻雨";
    }else if ([val isEqualToString:@"20"]){
        result=@"沙尘暴";
    }else if ([val isEqualToString:@"21"]){
        result=@"小到中雨";
    }else if ([val isEqualToString:@"22"]){
        result=@"中到大雨";
    }else if ([val isEqualToString:@"23"]){
        result=@"大到暴雨";
    }else if ([val isEqualToString:@"24"]){
        result=@"大暴雨到特大暴雨";
    }else if ([val isEqualToString:@"25"]){
        result=@"小到中雪";
    }else if ([val isEqualToString:@"26"]){
        result=@"中到大雪";
    }else if ([val isEqualToString:@"27"]){
        result=@"大到暴雪";
    }else if ([val isEqualToString:@"28"]){
        result=@"浮沙";
    }else if ([val isEqualToString:@"29"]){
        result=@"扬沙";
    }else if ([val isEqualToString:@"30"]){
        result=@"强沙尘暴";
    }else if ([val isEqualToString:@"53"]){
        result=@"霾";
    }else if ([val isEqualToString:@"99"]){
        result=@"无";
    }
    return result;
    
}

- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer, outBuffer2;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    outBuffer2.data = pixelBuffer;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,&outBuffer2,NULL,0,0,boxSize,boxSize,NULL,kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2,&inBuffer,NULL,0,0,boxSize,boxSize,NULL,kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer,&outBuffer,NULL,0,0,boxSize,boxSize,NULL,kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
