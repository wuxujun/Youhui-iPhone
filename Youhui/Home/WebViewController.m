//
//  WebViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/5.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "WebViewController.h"
#import "PathHelper.h"
#import "UIFont+Setting.h"
#import "UIViewController+NavigationBarButton.h"

@interface WebViewController()<UIWebViewDelegate>
{
    UIWebView           *mWebView;
}
@end

@implementation WebViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self addBackBarButton];
    self.view.backgroundColor=TABLE_BACKGROUND_COLOR;
    
    if (mWebView==nil) {
        mWebView=[[UIWebView alloc]initWithFrame:self.view.bounds];
        mWebView.delegate=self;
        mWebView.scalesPageToFit=NO;
        [mWebView setBackgroundColor:TABLE_BACKGROUND_COLOR];
        [self.view addSubview:mWebView];

    }
    UILabel* lab=[[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 34)];
    [lab setText:@"品牌介绍"];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView=lab;
    
    if (self.infoDict) {
        if ([self.infoDict objectForKey:@"title"]) {
            [lab setText:[self.infoDict objectForKey:@"title"]];
        }
        [mWebView loadHTMLString:[self htmlForContent:[self.infoDict objectForKey:@"content"]] baseURL:nil];
    }
}

- (NSString *)htmlForContent:(NSString *)content
{
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:[PathHelper filePathInMainBundle:@"MapDetail_template.html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *html = [NSString stringWithFormat:htmlTemplate, [UIFont currentSystemFontSizeBasedOn:14], 0, 0, 0, 0, content];
    return html;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{

}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    return YES;
}

@end
