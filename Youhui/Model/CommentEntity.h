//
//  CommentEntity.h
//  Youhui
//
//  Created by xujunwu on 15/4/18.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CommentEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * bid;
@property (nonatomic, retain) NSString * brandLogo;
@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * mid;
@property (nonatomic, retain) NSDate * sendTime;

@end
