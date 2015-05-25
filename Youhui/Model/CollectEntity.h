//
//  CollectEntity.h
//  Youhui
//
//  Created by xujunwu on 15/4/17.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CollectEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * mid;
@property (nonatomic, retain) NSNumber * bid;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSDate * addtime;

@end
