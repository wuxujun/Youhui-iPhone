//
//  PathHelper.m
//  Youhui
//
//  Created by xujunwu on 15/3/27.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "PathHelper.h"

@implementation PathHelper

+(NSString *)filePathInMainBundle:(NSString *)fileName{
    if (fileName.length > 0) {
        NSArray *keywords = [fileName componentsSeparatedByString:@"."];
        NSString *suffix = keywords[keywords.count - 1];
        NSInteger pathLength = fileName.length - suffix.length;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileName substringToIndex:pathLength - 1] ofType:suffix];
        return filePath;
    }
    return nil;
}

+ (NSString *)documentDirectory {
    static NSString *documentPath = nil;
    if (documentPath==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [paths objectAtIndex:0];
    }
    return documentPath;
}

+ (NSString *)filePathInDocument:(NSString *)filename {
    return [[self documentDirectory] stringByAppendingPathComponent:filename];
}

+ (NSString *)cacheDirectory{
    static NSString *cachePath = nil;
    if (cachePath==nil) {
        NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cachePath = [cache objectAtIndex:0] ;
    }
    return cachePath;
}

+ (NSString *)filePathInCacheDirectory:(NSString *)filename{
    return [[self cacheDirectory] stringByAppendingPathComponent:filename];
}


@end
