//
//  UIViewController+NavigationBarButton.m
//
//
//  Created by wuxujun on 13-8-20.
//
//

#import "UIViewController+NavigationBarButton.h"
#import "YSearchDisplayController.h"

@interface UIViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) YSearchDisplayController * searchDisplayController;

@end

@implementation UIViewController (NavigationBarButton)

- (void)adjustButtonForiOS7:(UIButton *)button left:(BOOL)isLeft
{
    if (iOS_VERSION_7) {
        if (isLeft) {
            button.contentEdgeInsets = UIEdgeInsetsMake(0, -19.0f, 0, 0.0f);
        }else{
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 0.0f, 0, -19.0f);
        }
    }
}

-(void)addBackBarButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(0, 0, 44.0f, 44.0f);
    
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"icon_back_selected"] forState:UIControlStateHighlighted];
    [button setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    [self adjustButtonForiOS7:button left:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)gotoBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#define TAG_CENTER_SEARCH  2001
- (void)addCenterSearchBar:(SEL)action
{
    UIImageView* s=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_search"]];
    [s setFrame:CGRectMake(18, 8, 18, 18)];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTag:TAG_CENTER_SEARCH];
    [button setFont:[UIFont systemFontOfSize:13.0]];
    [button setTitle:@"搜索你想要的品牌" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(70, 5, self.view.frame.size.width-140, 34.0);
    UIImage* bgImg=[UIImage imageNamed:@"Home_Search_Inputbg.png"];
    
    [button setBackgroundImage:[bgImg stretchableImageWithLeftCapWidth:20 topCapHeight:0] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [button addSubview:s];
    
    [self.navigationController.navigationBar addSubview:button];
}

-(void)addRightCityForWeather:(SEL)action
{
    
}

- (void)removeCenterSearchBar
{
    for (UIView* view in self.navigationController.navigationBar.subviews) {
        if (view.tag==TAG_CENTER_SEARCH) {
            [view removeFromSuperview];
        }
    }
}
- (void)addRightSearchButton:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(0, 0, 44.0f, 44.0f);
    [self adjustButtonForiOS7:button left:NO];
    
    [button setImage:[UIImage imageNamed:@"Search_Icon.png"] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)addRightFavoriteButton:(BOOL)isCollected action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(0, 0, 44.0f, 44.0f);
    [self adjustButtonForiOS7:button left:NO];
    
    NSString *imageName = isCollected ? @"Guidebook_Collect_Icon_Hold.png" : @"Guidebook_Collect_Icon.png";
    
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)addRightSettingButton:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(0, 0, 44.0f, 44.0f);
    [self adjustButtonForiOS7:button left:NO];
    
    [button setImage:[UIImage imageNamed:@"More_Seticon.png"] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)addWritePostBarButton:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44.0f, 44.0f);
    [button setImage:[UIImage imageNamed:@"Forum_Posting_Icon.png"] forState:UIControlStateNormal];
    [self adjustButtonForiOS7:button left:NO];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)addRightButtonWithTitle:(NSString *)title withSel:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 34);
    [button setBackgroundImage:[UIImage imageNamed:@"More_UserCenter_butt.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"More_UserCenter_butt_Press.png"] forState:UIControlStateHighlighted];
    [self adjustButtonForiOS7:button left:NO];
    
    UILabel *titleLabel = button.titleLabel;
    [titleLabel setTextColor:RGBCOLOR(229, 227, 227)];
    [titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (BOOL)viewWillDisappearDueToPushing:(UIViewController *)viewController
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == viewController) {
        // View is disappearing because a new view controller was pushed onto the stack
        return YES;
    }
    return NO;
}

- (BOOL)viewWillDisappearDueToPopping
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        return YES;
    }
    return NO;
}

@end
