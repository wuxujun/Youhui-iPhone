//
//  AMapViewController.m
//  Youhui
//
//  Created by xujunwu on 15/4/15.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "AMapViewController.h"

#import "UIViewController+NavigationBarButton.h"

@implementation AMapViewController
@synthesize mapView=_mapView;


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackBarButton];
    
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
    [lab setText:@"地图导航"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    
    if (self.mapView==nil) {
        self.mapView=[[MAMapView alloc]initWithFrame:self.view.bounds];
    }
 
    self.mapView.delegate=self;
    self.mapView.userTrackingMode=MAUserTrackingModeFollow;
    
    [self.view addSubview:self.mapView];
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.mapView.showsUserLocation=YES;
    
    
}

-(void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    
}

@end
