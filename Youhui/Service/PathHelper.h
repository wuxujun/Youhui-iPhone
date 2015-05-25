//
//  PathHelper.h
//  Youhui
//
//  Created by xujunwu on 15/3/27.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathHelper : NSObject
+ (NSString *)filePathInMainBundle:(NSString *)fileName;
+ (NSString *)filePathInCacheDirectory:(NSString *)filename;
+ (NSString *)filePathInDocument:(NSString *)filename;
+ (NSString *)documentDirectory;

@end
