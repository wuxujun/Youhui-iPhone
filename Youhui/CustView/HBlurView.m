//
//  HBlurView.m
//  Youhui
//
//  Created by xujunwu on 15/3/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "HBlurView.h"

@interface HGradientView : UIView

@end

@implementation HGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.colors = @[
                                 (id)[[UIColor colorWithWhite:0 alpha:1] CGColor],
                                 (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor],
                                 ];
    }
    return self;
}

@end

@interface HBlurView ()

@property (nonatomic, strong) HGradientView *gradientBackgroundView;
@property (nonatomic, strong) UIToolbar *blurBackgroundView;
@property (nonatomic, strong) UIView *blackTranslucentBackgroundView;
@property (nonatomic, strong) UIView *whiteBackgroundView;

@end

@implementation HBlurView

- (void)showBlurViewAtView:(UIView *)currentView {
    [self showAnimationAtContainerView:currentView];
}

- (void)showBlurViewAtViewController:(UIViewController *)currentViewContrller {
    [self showAnimationAtContainerView:currentViewContrller.view];
}

- (void)disMiss {
    [self hiddenAnimation];
}

#pragma mark - Private

- (void)showAnimationAtContainerView:(UIView *)containerView {
    if (self.showed) {
        [self disMiss];
        return;
    } else {
        if (self.willShowBlurViewcomplted) {
            self.willShowBlurViewcomplted();
        }
    }
    self.alpha = 0.0;
    [containerView insertSubview:self atIndex:0];
    [UIView animateWithDuration:self.showDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.showed = YES;
        if (self.didShowBlurViewcompleted) {
            self.didShowBlurViewcompleted(finished);
        }
    }];
}

- (void)hiddenAnimation {
    [self hiddenAnimationCompletion:^(BOOL finished) {
        
    }];
}

- (void)hiddenAnimationCompletion:(void (^)(BOOL finished))completion {
    if (self.willDismissBlurViewCompleted) {
        self.willDismissBlurViewCompleted();
    }
    
    [UIView animateWithDuration:self.disMissDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        if (self.didDismissBlurViewCompleted) {
            self.didDismissBlurViewCompleted(finished);
        }
        self.showed = NO;
        [self removeFromSuperview];
    }];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self hiddenAnimationCompletion:^(BOOL finished) {
        
    }];
}

#pragma mark - Propertys

- (void)setHasTapGestureEnable:(BOOL)hasTapGestureEnable {
    _hasTapGestureEnable = hasTapGestureEnable;
    [self setupTapGesture];
}

- (HGradientView *)gradientBackgroundView {
    if (!_gradientBackgroundView) {
        _gradientBackgroundView = [[HGradientView alloc] initWithFrame:self.bounds];
    }
    return _gradientBackgroundView;
}

- (UIToolbar *)blurBackgroundView {
    if (!_blurBackgroundView) {
        _blurBackgroundView = [[UIToolbar alloc] initWithFrame:self.bounds];
        [_blurBackgroundView setBarStyle:UIBarStyleBlackTranslucent];
    }
    return _blurBackgroundView;
}

- (UIView *)blackTranslucentBackgroundView {
    if (!_blackTranslucentBackgroundView) {
        _blackTranslucentBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _blackTranslucentBackgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    }
    return _blackTranslucentBackgroundView;
}

- (UIView *)whiteBackgroundView {
    if (!_whiteBackgroundView) {
        _whiteBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _whiteBackgroundView.backgroundColor = [UIColor clearColor];
        _whiteBackgroundView.tintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    }
    return _whiteBackgroundView;
}

- (UIView *)backgroundView {
    switch (self.blurStyle) {
        case HBlurStyleBlackGradient:
            return self.gradientBackgroundView;
            break;
        case HBlurStyleTranslucent:
            return self.blurBackgroundView;
        case HBlurStyleBlackTranslucent:
            return self.blackTranslucentBackgroundView;
            break;
        case HBlurStyleWhite:
            return self.whiteBackgroundView;
            break;
        default:
            break;
    }
}

#pragma mark - Life Cycle

- (void)setup {
    self.showDuration = self.disMissDuration = 0.3;
    self.blurStyle = HBlurStyleTranslucent;
    self.backgroundColor = [UIColor clearColor];
    
    _hasTapGestureEnable = NO;
}

- (void)setupTapGesture {
    if (self.hasTapGestureEnable) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        UIView *backgroundView = [self backgroundView];
        backgroundView.userInteractionEnabled = NO;
        [self addSubview:backgroundView];
    }
}

@end

#pragma mark - UIView XHRealTimeBlur分类的实现

@implementation UIView (XHRealTimeBlur)

#pragma mark - Show Block

- (WillShowBlurViewBlcok)willShowBlurViewcomplted {
    return objc_getAssociatedObject(self, &HWillShowBlurViewBlcokBlcokKey);
}

- (void)setWillShowBlurViewcomplted:(WillShowBlurViewBlcok)willShowBlurViewcomplted {
    objc_setAssociatedObject(self, &HWillShowBlurViewBlcokBlcokKey, willShowBlurViewcomplted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DidShowBlurViewBlcok)didShowBlurViewcompleted {
    return objc_getAssociatedObject(self, &HDidShowBlurViewBlcokBlcokKey);
}

- (void)setDidShowBlurViewcompleted:(DidShowBlurViewBlcok)didShowBlurViewcompleted {
    objc_setAssociatedObject(self, &HDidShowBlurViewBlcokBlcokKey, didShowBlurViewcompleted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - dismiss block

- (WillDismissBlurViewBlcok)willDismissBlurViewCompleted {
    return objc_getAssociatedObject(self, &HWillDismissBlurViewBlcokKey);
}

- (void)setWillDismissBlurViewCompleted:(WillDismissBlurViewBlcok)willDismissBlurViewCompleted {
    objc_setAssociatedObject(self, &HWillDismissBlurViewBlcokKey, willDismissBlurViewCompleted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (DidDismissBlurViewBlcok)didDismissBlurViewCompleted {
    return objc_getAssociatedObject(self, &HDidDismissBlurViewBlcokKey);
}

- (void)setDidDismissBlurViewCompleted:(DidDismissBlurViewBlcok)didDismissBlurViewCompleted {
    objc_setAssociatedObject(self, &HDidDismissBlurViewBlcokKey, didDismissBlurViewCompleted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - RealTimeBlur HUD


- (HBlurView *)realTimeBlur {
    return objc_getAssociatedObject(self, &HBlurKey);
}

- (void)setRealTimeBlur:(HBlurView *)realTimeBlur {
    objc_setAssociatedObject(self, &HBlurKey, realTimeBlur, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 分类 公开方法

- (void)showRealTimeBlurWithBlurStyle:(HBlurStyle)blurStyle {
    [self showRealTimeBlurWithBlurStyle:blurStyle hasTapGestureEnable:NO];
}

- (void)showRealTimeBlurWithBlurStyle:(HBlurStyle)blurStyle hasTapGestureEnable:(BOOL)hasTapGestureEnable {
    HBlurView *realTimeBlur = [self realTimeBlur];
    if (!realTimeBlur) {
        realTimeBlur = [[HBlurView alloc] initWithFrame:self.bounds];
        realTimeBlur.blurStyle = blurStyle;
        [self setRealTimeBlur:realTimeBlur];
    }
    realTimeBlur.hasTapGestureEnable = hasTapGestureEnable;
    
    realTimeBlur.willShowBlurViewcomplted = self.willShowBlurViewcomplted;
    realTimeBlur.didShowBlurViewcompleted = self.didShowBlurViewcompleted;
    
    realTimeBlur.willDismissBlurViewCompleted = self.willDismissBlurViewCompleted;
    realTimeBlur.didDismissBlurViewCompleted = self.didDismissBlurViewCompleted;
    
    [realTimeBlur showBlurViewAtView:self];
}

- (void)disMissRealTimeBlur {
    [[self realTimeBlur] disMiss];
}



@end
