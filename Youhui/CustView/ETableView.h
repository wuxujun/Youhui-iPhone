//
//  ETableView.h
//  Youhui
//
//  Created by xujunwu on 15/4/1.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>



@class ETableView;

@protocol ETableViewDelegate <UITableViewDataSource,UITableViewDelegate>

@required
- (NSInteger)tableView:(ETableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath;

- (UITableViewCell *)tableView:(ETableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (CGFloat)tableView:(ETableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(ETableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(ETableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath;


@end

@interface ETableView : UITableView

@property (nonatomic, weak) id <ETableViewDelegate> ETableViewDelegate;
@property (nonatomic, assign) BOOL shouldExpandOnlyOneCell;
- (void)refreshData;
- (void)refreshDataWithScrollingToIndexPath:(NSIndexPath *)indexPath;

- (void)collapseCurrentlyExpandedIndexPaths;

@end

#pragma mark - NSIndexPath (ETableView)
@interface NSIndexPath (ETableView)

@property (nonatomic, assign) NSInteger subRow;
+ (NSIndexPath *)indexPathForSubRow:(NSInteger)subrow inRow:(NSInteger)row inSection:(NSInteger)section;

@end
