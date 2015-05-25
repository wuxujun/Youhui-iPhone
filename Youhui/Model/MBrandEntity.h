//
//  MBrandEntity.h
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MBrandEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * mid;
@property (nonatomic, retain) NSNumber * mallId;
@property (nonatomic, retain) NSNumber * brandId;
@property (nonatomic, retain) NSNumber * floorId;
@property (nonatomic, retain) NSNumber * cateId;
@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) NSString * mallName;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * cateName;

@end
