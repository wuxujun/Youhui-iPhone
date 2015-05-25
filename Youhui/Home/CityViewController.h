//
//  CityViewController.h
//  Youhui
//
//  Created by xujunwu on 15/2/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface CityViewController : BaseViewController<CLLocationManagerDelegate>


@property(nonatomic,strong)NSMutableArray       *citys;
@end
