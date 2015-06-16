//
//  ETableViewCell.h
//  Youhui
//
//  Created by xujunwu on 15/4/2.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETableViewCell : UITableViewCell
/**
 * The boolean value showing the receiver is expandable or not. The default value of this property is NO.
 */
@property (nonatomic, assign, getter = isExpandable) BOOL expandable;

/**
 * The boolean value showing the receiver is expanded or not. The default value of this property is NO.
 */
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;

/**
 * Adds an indicator view into the receiver when the relevant cell is expanded.
 */
- (void)addIndicatorView;

/**
 * Removes the indicator view from the receiver when the relevant cell is collapsed.
 */
- (void)removeIndicatorView;

/**
 * Returns a boolean value showing if the receiver contains an indicator view or not.
 *
 *  @return The boolean value for the indicator view.
 */
- (BOOL)containsIndicatorView;

- (void)accessoryViewAnimation;


@end
