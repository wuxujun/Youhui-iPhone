//
//  YSearchDisplayController.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "YSearchDisplayController.h"
#import "UIViewController+NavigationBarButton.h"

@interface YSearchDisplayController()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,YSearchBarDelegate>

@end

@implementation YSearchDisplayController

- (id)initWithSearchContentType:(YContentType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.searchBar) {
        self.searchBar = [[YSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        self.searchBar.delegate = self;
        [self.searchBar setPlacehoder:self.searchBarPlaceholder];
    }else{
        self.searchBar.delegate = self;
    }
    
    CGRect bounds=self.view.frame;
   
    CGRect searchBarFrame = CGRectMake(0, 20, bounds.size.width, 44);
    self.searchBar.frame = searchBarFrame;
    [self.view addSubview:self.searchBar];
    
    CGRect tableViewFrame = self.view.bounds;
    tableViewFrame.origin.y = 64;
    tableViewFrame.size.height -= 64+49;
    
    self.searchResultsTableView = [[UITableView alloc] initWithFrame:tableViewFrame];
  //  self.view.backgroundColor = APP_BACKGROUND_COLOR;
    self.searchResultsTableView.backgroundColor = TABLE_BACKGROUND_COLOR;
    self.searchResultsTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.searchResultsTableView.delegate = self.searchResultsDataDelagate;
    self.searchResultsTableView.dataSource = self.searchResultsDataSource;
    [self.view addSubview:self.searchResultsTableView];
    
    self.searchResultsTableView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.searchResultsTableView.alpha = 1;
    }];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.searchBar.text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(ySearchDisplayController:searchString:)] && [self.searchResultsTableView numberOfRowsInSection:0] == 0) {
            [self.delegate ySearchDisplayController:self searchString:self.searchBar.text];
        }
    }else{
        [self showLogoView:YES];
        [self.searchBar beginEditting];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self viewWillDisappearDueToPushing:self.parentViewController]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)showLogoView:(BOOL)show
{
//    if (!self.logoView) {
//        self.logoView = [[DXYTipsView alloc] initWithType:DXYTipsViewTypeSearchLogo];
//        self.logoView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
//    }
//    
//    if (show) {
//        self.searchResultsTableView.hidden = YES;
//        CGFloat originX = (self.view.frame.size.width - self.logoView.frame.size.width) * 0.5;
//        [self.logoView showInView:self.view atPoint:CGPointMake(originX, 104)];
//    }else{
//        self.searchResultsTableView.hidden = NO;
//        [self.logoView remove];
//    }
}

#pragma mark - search bar delegate
- (void)searchBarCancelButtonClicked:(YSearchBar *)searchBar
{
    self.searchBar.text = nil;
    if ([self.delegate respondsToSelector:@selector(ySearchDisplayControllerDidEndSearch:)]) {
        [self.delegate ySearchDisplayControllerDidEndSearch:self];
    }
}

- (void)searchBarSearchButtonClicked:(YSearchBar *)searchBar searchString:(NSString *)searchString
{
    DLog(@"%@", searchString);
    if ([self.delegate respondsToSelector:@selector(ySearchDisplayController:searchString:)]) {
        [self.delegate ySearchDisplayController:self searchString:searchString];
    }
}

@end
