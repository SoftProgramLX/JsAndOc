//
//  LXWebViewController.h
//  OcAndJs
//
//  Created by apple on 15/4/1.
//  Copyright (c) 2015年 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXWebViewController : UIViewController

//web标题
@property(nonatomic,copy)NSString *userName;
//url链接地址
@property(nonatomic,copy)NSString *url;
//html链接地址
@property(nonatomic,copy)NSString *htmlString;

@end
