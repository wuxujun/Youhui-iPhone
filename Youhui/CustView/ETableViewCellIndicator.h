//
//  ETableViewCellIndicator.h
//  Youhui
//
//  Created by xujunwu on 15/4/2.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETableViewCellIndicator : UIView
/**
 * Returns the color of the indicator view.
 *
 *  @discussion By default, this value equals to the seperator color of the table view, and if the seperator color is changed,
 *               the color of the indicator value is set automatically, too.
 */
+ (UIColor *)indicatorColor;

/**
 * Sets the color of the indicator view.
 *
 *  @param indicatorColor The color of the indicator view.
 */
+ (void)setIndicatorColor:(UIColor *)indicatorColor;

@end
