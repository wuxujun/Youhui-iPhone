//
//  CityViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "CityViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "CityEntity.h"
#import "UserDefaultHelper.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "AppDelegate.h"

@interface CityViewController()<AMapSearchDelegate>
{
    CLLocationManager   *locManager;
    AMapSearchAPI       *_search;
    
    NSString*           currentCity;
    NSString*           currentCityCode;
}

@end

@implementation CityViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.citys=[[NSMutableArray alloc]init];
    
    
    [self addBackBarButton];
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
    [lab setText:@"城市选择"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    
    if ([CLLocationManager locationServicesEnabled]) {
        locManager=[[CLLocationManager alloc]init];
        locManager.delegate=self;
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=1000;
        if (IOS_VERSION_8) {
            [locManager requestAlwaysAuthorization];
        }
    }
    currentCity=@"定位中...";
    _search=[[AMapSearchAPI alloc]initWithSearchKey:AMPAP_KEY Delegate:self];
    
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=(id<UITableViewDelegate>)self;
        mTableView.dataSource=(id<UITableViewDataSource>)self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.backgroundColor=TABLE_BACKGROUND_COLOR;
        [self.view addSubview:mTableView];
    }
    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [locManager startUpdatingLocation];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     [locManager stopUpdatingLocation];
}

-(void)loadData
{
    
    NSArray * ay=[CityEntity MR_findAllSortedBy:@"code" ascending:YES];
    [self.citys addObjectsFromArray:ay];
    [mTableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return [self.citys count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"定位城市";
    }else{
        return @"热门城市";
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CGRect bounds=self.view.frame;
    cell.backgroundColor=TABLE_CELL_BACKGROUND_COLOR;
    if (indexPath.section==0) {
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20, (44-26)/2, 200, 26)];
        [label setText:currentCity];
        [label setTextColor:[UIColor whiteColor]];
        [cell addSubview:label];
    }else{
        CityEntity* entity=[self.citys objectAtIndex:indexPath.row];
        UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(20, (44-26)/2, 200, 26)];
        [label setText:entity.title];
        [label setTextColor:[UIColor whiteColor]];
        [cell addSubview:label];
    }
    UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 43, bounds.size.width, 1)];
    [line setBackgroundColor:TABLE_CELL_LINE_COLOR];
    [cell addSubview:line];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
        CityEntity* entity=[self.citys objectAtIndex:indexPath.row];
        if (entity) {
            [UserDefaultHelper setObject:entity.title forKey:CURRENT_CITY_TITLE];
            [UserDefaultHelper setObject:entity.code forKey:CURRENT_CITY_CODE];
        }
    }else{
        [UserDefaultHelper setObject:currentCityCode forKey:CURRENT_CITY_CODE];
        [UserDefaultHelper setObject:currentCity forKey:CURRENT_CITY_TITLE];
    }
    [self.navigationController popViewControllerAnimated:YES];
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
    DLog(@"%@  %@",latitude,longitude);
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
        DLog(@"%@",response.regeocode);
        if (response.regeocode.addressComponent.city!=nil) {
            currentCity=response.regeocode.addressComponent.city;
            currentCityCode=response.regeocode.addressComponent.citycode;
        }else{
            currentCity=response.regeocode.addressComponent.province;
            currentCityCode=response.regeocode.addressComponent.citycode;
        }
    }else{
        currentCity=@"无法定位";
    }
    [mTableView reloadData];
}


@end
