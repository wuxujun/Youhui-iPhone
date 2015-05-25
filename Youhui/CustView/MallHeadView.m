//
//  MallHeadView.m
//  Youhui
//
//  Created by xujunwu on 15/2/9.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "MallHeadView.h"

@implementation MallHeadView
@synthesize dict;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        delegate=aDelegate;
        [self initializeFields];
    }
    return self;
}

-(void)initializeFields
{
    
    contentView=[[UIView alloc]init];
    contentView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [contentView setBackgroundColor:TABLE_CELL_LINE_COLOR];
    mapBtn=[[UIButton alloc] init];
    [mapBtn setBackgroundColor:TABLE_CELL_BACKGROUND_COLOR];
    [mapBtn setTag:0];
    [mapBtn addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    mapLabel=[[UILabel alloc]init];
    [mapLabel setText:@"地图"];
    [mapLabel setTextColor:[UIColor whiteColor]];
    [mapBtn addSubview:mapLabel];
    mapImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_map"]];
    [mapBtn addSubview:mapImage];
    
    cateBtn=[[UIButton alloc]init];
    [cateBtn setBackgroundColor:TABLE_CELL_BACKGROUND_COLOR];
    [cateBtn setTag:1];
    [cateBtn addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    cateLabel=[[UILabel alloc]init];
    [cateLabel setTextColor:[UIColor whiteColor]];
    [cateLabel setText:@"类别"];
    [cateBtn addSubview:cateLabel];
    cateImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_cate"]];
    [cateBtn addSubview:cateImage];

    floorBtn=[[UIButton alloc]init];
    [floorBtn setBackgroundColor:TABLE_CELL_BACKGROUND_COLOR];
    [floorBtn setTag:2];
    [floorBtn addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
    floorLabel=[[UILabel alloc]init];
    [floorLabel setText:@"楼层"];
    [floorLabel setTextColor:[UIColor whiteColor]];
    [floorBtn addSubview:floorLabel];
    
    floorImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ic_floor"]];
    [floorBtn addSubview:floorImage];
    
    [contentView addSubview:mapBtn];
    [contentView addSubview:cateBtn];
    [contentView addSubview:floorBtn];
    [self addSubview:contentView];
    
    [self reAdjustLayout];
}

-(void)rotate:(UIInterfaceOrientation)interfaceOrientation animation:(BOOL)animation
{
    currrentInterfaceOrientation=interfaceOrientation;
    [self reAdjustLayout];
}

-(void)reAdjustLayout
{
    [contentView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

    CGSize areaSize=contentView.frame.size;
    float w=areaSize.width/3.0;
    [mapBtn setFrame:CGRectMake(0, 0, w, areaSize.height)];
    [mapImage setFrame:CGRectMake(w/2-36, (areaSize.height-36)/2, 36, 36)];
    [mapLabel setFrame:CGRectMake(w/2, (areaSize.height-26)/2, w/2, 26)];
    
    [cateBtn setFrame:CGRectMake(w+1, 0, w-2, areaSize.height)];
    [cateImage setFrame:CGRectMake(w/2-36, (areaSize.height-36)/2, 36, 36)];
    [cateLabel setFrame:CGRectMake(w/2, (areaSize.height-26)/2, w/2, 26)];
    
    [floorBtn setFrame:CGRectMake(w*2, 0, w, areaSize.height)];
    [floorImage setFrame:CGRectMake(w/2-36, (areaSize.height-36)/2, 36, 36)];
    [floorLabel setFrame:CGRectMake(w/2, (areaSize.height-26)/2, w/2, 26)];
    
}

-(IBAction)onClicked:(id)sender
{
    if ([delegate respondsToSelector:@selector(onMallHeadViewClicked:)]) {
        [delegate onMallHeadViewClicked:((UIButton*)sender).tag];
    }
}
-(void)setDict:(NSDictionary *)aDict
{
    dict=aDict;
    [self setNeedsDisplay];
}


@end
