# OcAndJs
##此demo实现OC和JS交互，OC与JS相互调用，其中写一个静态的HTML文件，提供JS方法。
###效果图如下:<br>
![image](https://github.com/SoftProgramLX/OcAndJs/blob/master/OcAndJs/screen.png)
<br>

-----

##`一.OC调用JS:`
  不说闲话，看代码如下
* 需要先在js文件定义方法postStr供oc调用
```javascript
  function postStr(string) {
		return 'I am the return parameter JS, and param ' + string;
	}
```
* oc代码只需一句即可调用

```objective-c
  NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"postStr('ocToJs')"];
  //输出str为I am the return parameter JS, and param ocToJs，正式js中postStr方法的返回值。
```
	需注意的是正确书写@"postStr('ocToJs')"的格式，postStr为js方法，ocToJs是OC传递给JS的参数。

-----

##`二.JS调用OC:`
* 在h5页面添加了了button元素，用于触发js方法jsCallOCClicked
```html
  <button onclick="jsCallOCClicked()">
    <h1>jsCallOC</h1>
  </button>
```
* 在js文件的jsCallOCClicked()方法中去调用OC的jsCallToOC()方法
```javascript
  function jsCallOCClicked() {
		window.location.href = "objc://jsCallToOC#param#github地址#param#https://github.com/SoftProgramLX/OcAndJs";
	}
```
	说明：<br>
	1.“objc://”为自定义的OC识别JS调用的标识<br>
	2.“jsCallToOC”为需调用的OC方法<br>
	3.“#param#”为自定义的方法与参数或参数与参数的分隔符<br>
	4.“github地址”为js传递给OC的第一个参数<br>
	5.“https://github.com/SoftProgramLX/OcAndJs”为js传递给OC的第二个参数<br>

* 实现OC的jsCallToOC()方法

```objective-c
- (void)jsCallToOC:(NSArray *)params
{
    dataArr = params;
    alertV = [[UIAlertView alloc] initWithTitle:@"js已经调用了OC方法" message:@"查看控制台的信息，点击取消会再触发OC调用js" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertV.tag = 9666;
    [alertV show];
    
    NSLog(@"js调用OC返回值：%@", params);
}
```
	这里params[0]输出是github地址，params[1]输出是https://github.com/SoftProgramLX/OcAndJs

* 关键所在<br>
	目前JS调用OC的jsCallToOC()方法还不会触发，当点击h5页面的按钮时只会触发OC的- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;这个方法。<br>
	需在这个方法里解析request参数的URL值，解析后path的值就是"objc://jsCallToOC#param#github地址#param#https://github.com/SoftProgramLX/OcAndJs"，再继续分解出里面的方法与参数，然后执行[self performSelector:todoM withObject:params afterDelay:0];代码才能触发OC的jsCallToOC()方法。<br>
代码如下：<br>

```objective-c
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
```
	说明：<br>
	这里判断sels.count>1的目的是判断有无传参<br>
	若无参数则定义方法- (void)jsCallToOC；<br>
	若有参数则定义方法- (void)jsCallToOC:(NSArray *)params。

-----

##`三.额外方法`
* 禁止复制网页文字

```objective-c
- (void)deletePrompt
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}
```
* 用于js统计

```objective-c
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
```
QQ：2239344645
