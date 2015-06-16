//
//  CoverFlowView.h
//  Youhui
//
//  Created by xujunwu on 15/2/26.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverFlowView : UIView

//setup numbers of images
@property (nonatomic) int sideVisibleImageCount;

//setup the scale of left/right side and middle one
@property (nonatomic) CGFloat sideVisibleImageScale;
@property (nonatomic) CGFloat middleImageScale;

//source images
@property (nonatomic, retain) NSMutableArray *images;

//images layers, to help remove previous sublayer
@property (nonatomic, retain) NSMutableArray *imageLayers;

//template layers , to pre-locate every geometry info of layer
@property (nonatomic, retain) NSMutableArray *templateLayers;

//index in images for image rendering in the middle of cover flow
@property (nonatomic) int currentRenderingImageIndex;

//show the progress of browser : pagecontrol
@property (nonatomic, retain) UIPageControl *pageControl;

//factory method
+ (id)coverFlowViewWithFrame:(CGRect)frame
                   andImages: (NSMutableArray *)rawImages
              sideImageCount:(int) sideCount
              sideImageScale: (CGFloat) sideImageScale
            middleImageScale: (CGFloat) middleImageScale;

//get index for current image that in the middle in images
- (int)getIndexForMiddle;

@end
