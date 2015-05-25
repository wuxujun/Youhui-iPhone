//
//  NoticeViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/30.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "NoticeViewController.h"
#import "MessageViewController.h"
#import "AppDelegate.h"
#import "UIViewController+NavigationBarButton.h"

@interface NoticeViewController()<ViewPagerDataSource,ViewPagerDelegate>

@property (nonatomic)NSUInteger     numberOfTabs;
@property (nonatomic,strong)UILabel     *titleLab;

@property (nonatomic,strong)MessageViewController*  noticeController;
@property (nonatomic,strong)MessageViewController*  systemController;

@end

@implementation NoticeViewController

-(id)init
{
    self=[super init];
    if (self) {
       
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBackBarButton];
    if (self.infoDict) {
        DLog(@"%@",self.infoDict);
        
    }
    
    self.titleLab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, self.view.frame.size.width-120, 34)];
    [self.titleLab setText:@"广播"];
    [self.titleLab setTextAlignment:NSTextAlignmentCenter];
    [self.titleLab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=self.titleLab;
    
    self.noticeController=[[MessageViewController alloc]init];
    self.noticeController.title=@"广播";
    self.noticeController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"type", nil];
    
    self.systemController=[[MessageViewController alloc]init];
    self.systemController.title=@"系统消息";
    self.systemController.infoDict=[NSDictionary dictionaryWithObjectsAndKeys:@"1",@"type", nil];

    self.dataSource=self;
    self.delegate=self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)loadData
{
    self.numberOfTabs=2;
}

-(void)setNumberOfTabs:(NSUInteger)numberOfTabs
{
    _numberOfTabs=numberOfTabs;
    [self reloadData];
    [self selectTabAtIndex:0];
}

-(NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return self.numberOfTabs;
}

-(UIView*)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    NSArray *titles = @[@"广播", @"系统消息"];
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = titles[index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    return label;
}

-(UIViewController*)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index
{
    if (index==0) {
        return self.noticeController;
    }else {
        return self.systemController;
    }
}
#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 44.0;
        case ViewPagerOptionTabOffset:
            return 0.0;
        case ViewPagerOptionTabWidth:
            return self.view.frame.size.width/2;
        case ViewPagerOptionFixFormerTabsPositions:
            return 0.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return TAB_BACKGROUND_COLOR;
        case ViewPagerTabsView:
            return TABLE_BACKGROUND_COLOR;
        case ViewPagerContent:
            return TABLE_BACKGROUND_COLOR;
        default:
            return color;
    }
}

-(void)viewPager:(ViewPagerController *)viewPager didChangeTabToIndex:(NSUInteger)index
{
    NSArray *titles = @[@"广播", @"系统消息"];
    [self.titleLab setText:titles[index]];
    
}
@end
