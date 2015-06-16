//
//  UIViewController+NavigationBarButton.h
//
//
//  Created by wuxujun on 13-8-20.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationBarButton)

- (void)addCenterSearchBar:(SEL)action;
- (void)addRightCityForWeather:(SEL)action;
- (void)removeCenterSearchBar;
- (void)addBackBarButton;
- (void)addRightSearchButton:(SEL)action;
- (void)addRightFavoriteButton:(BOOL)isCollected action:(SEL)action;
- (void)addRightSettingButton:(SEL)action;
- (void)addRightButtonWithTitle:(NSString *)title withSel:(SEL)action;
- (void)addWritePostBarButton:(SEL)action;
- (BOOL)viewWillDisappearDueToPushing:(UIViewController *)viewController;
- (BOOL)viewWillDisappearDueToPopping;

@end
