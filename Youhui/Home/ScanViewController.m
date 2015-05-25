//
//  ScanViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/4.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "ScanViewController.h"
#import "ScanView.h"

@interface ScanViewController()

@property ZBarReaderView        *readerView;

@end

@implementation ScanViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=APP_BACKGROUND_COLOR;
    
    UIButton * closeBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-50, 20, 44, 44)];
    [closeBtn setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    
    self.readerView=[[ZBarReaderView alloc] init];
    CGRect frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
    if (iOS_VERSION_7) {
        frame=CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-44);
    }
    self.readerView.frame=frame;
    self.readerView.readerDelegate=self;
    self.readerView.allowsPinchZoom=false;
    self.readerView.torchMode=0;
    
    ScanView *scanView=[[ScanView alloc]initWithFrame:self.view.bounds];
    [scanView setBackgroundColor:[UIColor clearColor]];
    
    [self.readerView addSubview:scanView];
    
    CGRect scanRect=CGRectMake(60, CGRectGetMinY(self.readerView.frame)-126, 200, 200);
    [self.view addSubview:self.readerView];
    ZBarImageScanner *scanner=self.readerView.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    self.readerView.scanCrop=[self getScanCrop:scanRect readerViewBounds:self.readerView.bounds];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.readerView start];
}


-(IBAction)close:(id)sender
{
    [self.readerView stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    x=rect.origin.x/readerViewBounds.size.width;
    y=rect.origin.y/readerViewBounds.size.height;
    width=rect.size.width/readerViewBounds.size.width;
    height=rect.size.height/readerViewBounds.size.height;
    return CGRectMake(x,y, width, height);
}

-(void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    NSString   *searchKey=nil;
    for (ZBarSymbol *symbol in symbols) {
        DLog(@"%@",symbol.data);
        searchKey=symbol.data;
        break;
    }
    [readerView stop];
    if (![[self modalViewController] isBeingDismissed]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}
@end
