//
//  BrandTViewController.m
//  Youhui
//
//  Created by xujunwu on 15/3/20.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "BrandTViewController.h"
#import "BrandTCViewController.h"
#import "UIViewController+NavigationBarButton.h"

@interface BrandTViewController()<ViewPagerDataSource,ViewPagerDelegate>

@property (nonatomic)NSUInteger     numberOfTabs;

@property (nonatomic,strong)BrandTCViewController* controller1;
@property (nonatomic,strong)BrandTCViewController* controller2;
@property (nonatomic,strong)BrandTCViewController* controller3;
@property (nonatomic,strong)BrandTCViewController* controller4;


@end

@implementation BrandTViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackBarButton];
    
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
    [lab setText:@"品牌推荐"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    
    self.controller1=[[BrandTCViewController alloc]init];
    self.controller1.title=@"女装";
    self.controller1.type=@"100";
    self.controller1.infoDict=self.infoDict;
    
    self.controller2=[[BrandTCViewController alloc]init];
    self.controller2.title=@"男装";
    self.controller2.type=@"101";
    
    self.controller2.infoDict=self.infoDict;
    
    self.controller3=[[BrandTCViewController alloc]init];
    self.controller3.title=@"饰品";
    self.controller3.type=@"105";
    self.controller3.infoDict=self.infoDict;
    
    self.controller4=[[BrandTCViewController alloc]init];
    self.controller4.title=@"鞋子";
    self.controller4.type=@"102";
    self.controller4.infoDict=self.infoDict;
    
    self.dataSource=self;
    self.delegate=self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];
}

-(void)didReceiveMemoryWarning
{
    
}

-(void)loadData
{
    self.numberOfTabs=4;
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
    NSArray *titles = @[@"女装", @"男装",@"饰品",@"鞋子"];
    
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
        return self.controller1;
    }else if(index==1) {
        return self.controller2;
    }else if(index==2){
        return self.controller3;
    }else{
        return self.controller4;
    }
}

-(CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value
{
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 0.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 0.0;
        case ViewPagerOptionTabWidth:
            return self.view.frame.size.width/4;
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
@end
