//
//  YSearchDisplayController.h
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSearchBar.h"

@class YSearchDisplayController;
@protocol YSearchDisplayDelegate <NSObject>

@optional
- (void)ySearchDisplayControllerDidBeginSearch:(YSearchDisplayController *)controller;
- (void)ySearchDisplayControllerDidEndSearch:(YSearchDisplayController *)controller;
- (void)ySearchDisplayController:(YSearchDisplayController *)controller searchString:(NSString *)searchString;

@end

@interface YSearchDisplayController : UIViewController

@property (weak, nonatomic) id<YSearchDisplayDelegate> delegate;
@property (strong, nonatomic) YSearchBar * searchBar;
@property (strong, nonatomic) UITableView * searchResultsTableView;
@property (strong, nonatomic) id<UITableViewDelegate> searchResultsDataDelagate;
@property (strong, nonatomic) id<UITableViewDataSource> searchResultsDataSource;
@property (assign, nonatomic) YContentType type;
@property (strong, nonatomic) NSString *searchBarPlaceholder;

- (id)initWithSearchContentType:(YContentType)type;

- (void)showLogoView:(BOOL)show;

@end
