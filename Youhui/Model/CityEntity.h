//
//  CityEntity.h
//  Youhui
//
//  Created by xujunwu on 15/2/23.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CityEntity : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * title;

@end
