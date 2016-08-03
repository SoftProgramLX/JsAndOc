//
//  LXWebViewController.m
//  OcAndJs
//
//  Created by apple on 15/4/1.
//  Copyright (c) 2015年 LX. All rights reserved.
//

#import "LXWebViewController.h"

@interface LXWebViewController () <UIWebViewDelegate, UIAlertViewDelegate>
{
    UIAlertView *alertV;
    NSArray *dataArr;
}

@property (retain, nonatomic)UIWebView *webView;

@end

@implementation LXWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height+20)];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    [self.view addSubview:_webView];
    
    if (self.htmlString) {
        [self.webView loadHTMLString:self.htmlString baseURL:[NSURL URLWithString:self.url]];
    } else {
        NSURL * url = [NSURL URLWithString:self.url];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

#pragma mark -- UIWebViewDelegate委托定义方法

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *path =  [[request URL] absoluteString];
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0) {
        path = [path stringByRemovingPercentEncoding];
    }else{
        path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if ([path hasPrefix:@"ios"]||[path hasPrefix:@"objc"]) {
        NSString *method = [path substringFromIndex:@"objc://".length];
        NSArray *sels = [method componentsSeparatedByString:@"#param#"];
        SEL todoM;
        if (sels.count>1) {
            todoM = NSSelectorFromString([NSString stringWithFormat:@"%@:",sels[0]]);
            NSMutableArray *params = [NSMutableArray array];
            for (int i=1; i<sels.count; i++) {
                [params addObject:sels[i]];
            }
            if ([self respondsToSelector:todoM]) {
                [self performSelector:todoM withObject:params afterDelay:0];
            }
        }else if(sels.count==1){
            todoM = NSSelectorFromString([NSString stringWithString:sels[0]]);
            if ([self respondsToSelector:todoM]) {
                [self performSelector:todoM withObject:nil afterDelay:0];
            }
        }
        return NO;
    }
    
    return YES;
}

- (void)jsCallToOC:(NSArray *)params
{
    dataArr = params;
    alertV = [[UIAlertView alloc] initWithTitle:@"js已经调用了OC方法" message:@"查看控制台的信息，点击取消会再触发OC调用js" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertV.tag = 9666;
    [alertV show];
    
    NSLog(@"js调用OC返回值：%@", params);
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != 9666) {
        return;
    }
    
    if (buttonIndex == 0) {
        NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"postStr(\"ocToJs\");"];
        NSLog(@"OC调用js返回值：%@",str);
        
        alertV = [[UIAlertView alloc] initWithTitle:nil message:str delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertV show];
    } else {
        LXWebViewController *webVC = [[LXWebViewController alloc] init];
        webVC.title = dataArr[0];
        webVC.url = dataArr[1];
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self deletePrompt];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

#pragma mark - private methods

//用于js统计
- (void)jsStatistics
{
    NSString *systemUserAgent = [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    if (!([systemUserAgent rangeOfString:@"****-app-iphone Version/"].length > 0)) {
        NSString *currentVersion = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleVersionKey];
        systemUserAgent = [systemUserAgent stringByAppendingFormat:@" ***-app-iphone Version/%@", currentVersion];
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:systemUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

//禁止复制
- (void)deletePrompt 
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

@end



