//
//  BaseViewController.h
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import "HNetworkEngine.h"


@interface BaseViewController : UIViewController
{
    
    UITableView*        mTableView;
    MBProgressHUD*      loading;

    NSMutableArray      *datas;
    
    UILabel             *titleLabel;
    
    float               cellHeight;
}
@property (nonatomic,strong)NSDictionary*   infoDict;
@property (nonatomic,strong)HNetworkEngine* networkEngine;

-(IBAction)openMessage:(id)sender;
-(IBAction)citySelect:(id)sender;

-(void)alertRequestResult:(NSString*)msg isPop:(BOOL)flag;
-(void)alertRequestResult:(NSString *)msg isDisses:(BOOL)flag;
@end
