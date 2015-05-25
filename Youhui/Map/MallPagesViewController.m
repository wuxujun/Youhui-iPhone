//
//  MallPagesViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/6.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MallPagesViewController.h"
#import "UIViewController+NavigationBarButton.h"
#import "MallLayoutViewController.h"
#import "MapCateViewController.h"
#import "MapPicViewController.h"
#import "UserDefaultHelper.h"

@interface MallPagesViewController()<ViewPagerDataSource,ViewPagerDelegate>
{
    int                 currentTabIndex;
}
@property (nonatomic)NSUInteger         numberOfTabs;

@property (nonatomic,strong)MapPicViewController* layoutController1;
@property (nonatomic,strong)MapCateViewController* layoutController2;
@property (nonatomic,strong)MallLayoutViewController* layoutController3;
@property (nonatomic,strong)MallLayoutViewController* layoutController4;

@end

@implementation MallPagesViewController

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
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:[self.infoDict objectForKey:@"mallName"]];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
    }
    
    self.layoutController1=[[MapPicViewController alloc]init];
    self.layoutController1.title=@"地图";
    
    self.layoutController2=[[MapCateViewController alloc]init];
    self.layoutController2.title=@"类别";
    
    self.layoutController3=[[MallLayoutViewController alloc]init];
    self.layoutController3.title=@"楼层";
    
    if (self.infoDict) {
        self.layoutController1.infoDict=self.infoDict;
        self.layoutController2.infoDict=self.infoDict;
        self.layoutController3.infoDict=self.infoDict;
    }
    
    self.dataSource=self;
    self.delegate=self;
    currentTabIndex=self.tabIndex;
    [UserDefaultHelper setObject:[NSString stringWithFormat:@"%d",currentTabIndex] forKey:MAP_TAB_INDEX];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ( [UserDefaultHelper objectForKey:MAP_TAB_INDEX]) {
        currentTabIndex=[[UserDefaultHelper objectForKey:MAP_TAB_INDEX] intValue];
    }else{
        currentTabIndex=self.tabIndex;
    }
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
    self.numberOfTabs=3;
}

-(void)setNumberOfTabs:(NSUInteger)numberOfTabs
{
    _numberOfTabs=numberOfTabs;
    [self reloadData];
    [self selectTabAtIndex:currentTabIndex];
}

-(NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager
{
    return self.numberOfTabs;
}

-(UIView*)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index
{
    NSArray *titles = @[@"地图", @"类别",@"楼层"];
    
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
        return self.layoutController1;
    }else  if (index==1) {
        return self.layoutController2;
    }else {
        return self.layoutController3;
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
            return self.view.frame.size.width/3;
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
    [UserDefaultHelper setObject:[NSString stringWithFormat:@"%d",index] forKey:MAP_TAB_INDEX];
    
}

@end
