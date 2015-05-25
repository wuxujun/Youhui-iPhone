//
//  MallPagesViewController.h
//  Youhui
//
//  Created by xujunwu on 15/2/6.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewPagerController.h"

@interface MallPagesViewController : ViewPagerController

@property(nonatomic,strong)NSDictionary*        infoDict;
@property(nonatomic,assign)int                  tabIndex;

@end
