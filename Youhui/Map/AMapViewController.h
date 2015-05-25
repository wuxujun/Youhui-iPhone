//
//  AMapViewController.h
//  Youhui
//
//  Created by xujunwu on 15/4/15.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>

@interface AMapViewController : UIViewController<MAMapViewDelegate>

@property (nonatomic,strong)MAMapView       *mapView;

@end
