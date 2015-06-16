//
//  HPagesContainerTopBar.h
//  Youhui
//
//  Created by xujunwu on 15/2/6.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HPagesContainerTopBar;

@protocol HPagesContainerTopBarDelegate <NSObject>

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(HPagesContainerTopBar *)bar;

@end

@interface HPagesContainerTopBar : UIView

@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIColor *itemTitleColor;
@property (strong, nonatomic) NSArray *itemTitles;
@property (strong, nonatomic) UIFont *font;
@property (readonly, strong, nonatomic) NSArray *itemViews;
@property (readonly, strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) id<HPagesContainerTopBarDelegate> delegate;

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index;
- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index;

@end
