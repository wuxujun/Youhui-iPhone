//
//  WealViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "WealViewController.h"

@interface WealViewController()

@end

@implementation WealViewController

-(id)init
{
    self=[super init];
    if (self) {
        self.title=@"福";
        UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
        [lab setText:@"福利"];
        [lab setTextAlignment:NSTextAlignmentCenter];
        [lab setTextColor:[UIColor whiteColor]];
        self.navigationItem.titleView=lab;
        [self.tabBarItem setImage:[UIImage imageNamed:@"Weal"]];
        [self.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (mTableView==nil) {
        mTableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        mTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        mTableView.delegate=(id<UITableViewDelegate>)self;
        mTableView.dataSource=(id<UITableViewDataSource>)self;
        mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        mTableView.rowHeight=121.0f;
        mTableView.backgroundColor=RGBCOLOR(30, 33, 38);
        [self.view addSubview:mTableView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    UIImageView* img=[[UIImageView alloc]initWithFrame:CGRectMake(0, 1, cell.frame.size.width, 120)];
    [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",(indexPath.row+1)]]];
    [cell addSubview:img];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)burstTapCircle:(UITableViewCell*)cell
{
    //NSLog(@"expanding a bit more");
    
    // Calculate the tap circle's ending diameter:
//    CGFloat tapCircleFinalDiameter = [self calculateTapCircleFinalDiameterForRect:self.currentTabRect];
//    tapCircleFinalDiameter += self.tapCircleBurstAmount;
//    
//    // Animation Mask Rects
//    CGPoint center = CGPointMake(CGRectGetMidX(self.currentTabRect), CGRectGetMidY(self.currentTabRect));
//    CGPoint origin = self.rippleFromTapLocation ? self.tapPoint : center;
//    
//    UIBezierPath *endingCirclePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(origin.x - (tapCircleFinalDiameter / 2.f),
//                                                                                        origin.y - (tapCircleFinalDiameter / 2.f),
//                                                                                        tapCircleFinalDiameter,
//                                                                                        tapCircleFinalDiameter)
//                                                                cornerRadius:tapCircleFinalDiameter / 2.f];
//    
//    // Get the next tap circle to expand:
//    CAShapeLayer *tapCircle = [self.rippleAnimationQueue firstObject];
//    if (self.rippleAnimationQueue.count > 0) {
//        [self.rippleAnimationQueue removeObjectAtIndex:0];
//    }
//    [self.deathRowForCircleLayers addObject:tapCircle];
//    
//    
//    CGPathRef startingPath = tapCircle.path;
//    CGFloat startingOpacity = tapCircle.opacity;
//    
//    if ([[tapCircle animationKeys] count] > 0) {
//        startingPath = [[tapCircle presentationLayer] path];
//        startingOpacity = [[tapCircle presentationLayer] opacity];
//    }
//    
//    // Burst tap-circle:
//    CABasicAnimation *tapCircleGrowthAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//    tapCircleGrowthAnimation.duration = 1.5;
//    tapCircleGrowthAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//    tapCircleGrowthAnimation.fromValue = (__bridge id)startingPath;
//    tapCircleGrowthAnimation.toValue = (__bridge id)endingCirclePath.CGPath;
//    tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
//    tapCircleGrowthAnimation.removedOnCompletion = NO;
//    
//    // Fade tap-circle out:
//    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    [fadeOut setValue:@"fadeCircleOut" forKey:@"id"];
//    fadeOut.delegate = self;
//    fadeOut.fromValue = [NSNumber numberWithFloat:startingOpacity];
//    fadeOut.toValue = [NSNumber numberWithFloat:0.f];
//    fadeOut.duration =1.5;
//    fadeOut.fillMode = kCAFillModeForwards;
//    fadeOut.removedOnCompletion = NO;
//    
//    [tapCircle addAnimation:tapCircleGrowthAnimation forKey:@"animatePath"];
//    [tapCircle addAnimation:fadeOut forKey:@"opacityAnimation"];
}
@end
