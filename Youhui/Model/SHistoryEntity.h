//
//  SHistoryEntity.h
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SHistoryEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * hid;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * searchKey;
@property (nonatomic, retain) NSNumber * nums;
@property (nonatomic, retain) NSDate * addTime;

@end
