//
//  UIButton+Category.h
//  Youhui
//
//  Created by xujunwu on 15/3/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Font.h"

@interface UIButton(Category)
- (void)addAwesomeIcon:(FAIcon)icon beforeTitle:(BOOL)before;
-(void)bootstrapStyle;
-(void)defaultStyle;
-(void)primaryStyle;
-(void)successStyle;
-(void)infoStyle;
-(void)warningStyle;
-(void)dangerStyle;
-(void)customSearchStyle;
-(void)customSearchLightStyle;
@end
