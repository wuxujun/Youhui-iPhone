//
//  UIImage+fixOrientation.h
//  
//
//  Created by wuxujun  on 12-3-6.
//  Copyright (c) 2012年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Custome)

- (UIImage *)fixOrientation;
/* blur the current image with a box blur algoritm */
- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur;

/* blur the current image with a box blur algoritm and tint with a color */
- (UIImage*)drn_boxblurImageWithBlur:(CGFloat)blur withTintColor:(UIColor*)tintColor;

- (UIImage *)pr_boxBlurredImageWithRadius:(CGFloat)radius;


- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
@end
