//
//  HomeViewController.h
//  Youhui
//
//  Created by xujunwu on 15/1/29.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "HPageControl.h"


@interface HomeViewController : BaseViewController<CLLocationManagerDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>


@end

