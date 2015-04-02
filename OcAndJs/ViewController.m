//
//  ViewController.m
//  OcAndJs
//
//  Created by apple on 15/4/1.
//  Copyright (c) 2015年 LX. All rights reserved.
//

#import "ViewController.h"
#import "LXWebViewController.h"

#define kMainScreenWidth  ([UIScreen mainScreen].applicationFrame.size.width)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1];
    
    self.navigationItem.title = @"Interactive exercises OC and JS";
    
    
    UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth/2.0 - 80, 180, 160, 30)];
    but.backgroundColor = [UIColor blueColor];
    [but setTitle:@"点击进入WebView" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [but addTarget:self action:@selector(butClickded:) forControlEvents:UIControlEventTouchUpInside];
    but.layer.cornerRadius = 4;
    but.layer.masksToBounds = YES;
    [self.view addSubview:but];
 }
    
- (void)butClickded:(id)sender
{
    LXWebViewController *webVC = [[LXWebViewController alloc] init];
    webVC.title = @"自建html5";
    
    //将html5文件用浏览器打开，把网址复制赋值到下面的webVC.url；现在的网址是在我的浏览器上生成的，你打不开。
//    webVC.url = @"file:///Users/apple/Desktop/%E7%BB%83%E4%B9%A0/OcAndJs/OcAndJs/html5.html";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"html5" ofType:@"html"];
    webVC.htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
