//
//  HBlurView.h
//  Youhui
//
//  Created by xujunwu on 15/3/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void(^WillShowBlurViewBlcok)(void);
typedef void(^DidShowBlurViewBlcok)(BOOL finished);

typedef void(^WillDismissBlurViewBlcok)(void);
typedef void(^DidDismissBlurViewBlcok)(BOOL finished);


static NSString * const HBlurKey = @"XHRealTimeBlurKey";

static NSString * const HWillShowBlurViewBlcokBlcokKey = @"HWillShowBlurViewBlcokBlcokKey";
static NSString * const HDidShowBlurViewBlcokBlcokKey = @"HDidShowBlurViewBlcokBlcokKey";

static NSString * const HWillDismissBlurViewBlcokKey = @"HWillDismissBlurViewBlcokKey";
static NSString * const HDidDismissBlurViewBlcokKey = @"HDidDismissBlurViewBlcokKey";

typedef NS_ENUM(NSInteger, HBlurStyle) {
    // 垂直梯度背景从黑色到半透明的。
    HBlurStyleBlackGradient = 0,
    // 类似UIToolbar的半透明背景
    HBlurStyleTranslucent,
    // 黑色半透明背景
    HBlurStyleBlackTranslucent,
    // 纯白色
    HBlurStyleWhite
};

@interface HBlurView : UIView

/**
 *  Default is XHBlurStyleTranslucent
 */
@property (nonatomic, assign) HBlurStyle blurStyle;

@property (nonatomic, assign) BOOL showed;

// Default is 0.3
@property (nonatomic, assign) NSTimeInterval showDuration;

// Default is 0.3
@property (nonatomic, assign) NSTimeInterval disMissDuration;

/**
 *  是否触发点击手势，默认关闭
 */
@property (nonatomic, assign) BOOL hasTapGestureEnable;

@property (nonatomic, copy) WillShowBlurViewBlcok willShowBlurViewcomplted;
@property (nonatomic, copy) DidShowBlurViewBlcok didShowBlurViewcompleted;

@property (nonatomic, copy) WillDismissBlurViewBlcok willDismissBlurViewCompleted;
@property (nonatomic, copy) DidDismissBlurViewBlcok didDismissBlurViewCompleted;


- (void)showBlurViewAtView:(UIView *)currentView;

- (void)showBlurViewAtViewController:(UIViewController *)currentViewContrller;

- (void)disMiss;

@end

@interface UIView (HBlurView)

@property (nonatomic, copy) WillShowBlurViewBlcok willShowBlurViewcomplted;
@property (nonatomic, copy) DidShowBlurViewBlcok didShowBlurViewcompleted;


@property (nonatomic, copy) WillDismissBlurViewBlcok willDismissBlurViewCompleted;
@property (nonatomic, copy) DidDismissBlurViewBlcok didDismissBlurViewCompleted;

- (void)showRealTimeBlurWithBlurStyle:(HBlurStyle)blurStyle;
- (void)showRealTimeBlurWithBlurStyle:(HBlurStyle)blurStyle hasTapGestureEnable:(BOOL)hasTapGestureEnable;
- (void)disMissRealTimeBlur;

@end
