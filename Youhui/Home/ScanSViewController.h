//
//  ScanSViewController.h
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ScanSViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong)AVCaptureDevice *device;
@property (nonatomic,strong)AVCaptureDeviceInput        *input;
@property (nonatomic,strong)AVCaptureMetadataOutput     *output;
@property (nonatomic,strong)AVCaptureSession            *session;
@property (nonatomic,strong)AVCaptureVideoPreviewLayer  *preview;
@property (nonatomic,retain)UIImageView                 *line;

@end
