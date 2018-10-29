//
//  MOBJSPostViewController.m
//  TestJS
//
//  Created by 崔林豪 on 2018/10/26.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import "MOBJSPostViewController.h"
#import <WebKit/WebKit.h>


@interface MOBJSPostViewController ()<WKUIDelegate,WKNavigationDelegate>


@property (nonatomic, assign) BOOL needLoadJSPOST;

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation MOBJSPostViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发送POST请求";
    [self _testJS];
    
}

- (void)_testJS
{
    // JS发送POST的Flag，为真的时候会调用JS的POST方法（仅当第一次的时候加载本地JS）
    self.needLoadJSPOST = YES;
    //创建WKWebView
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    //获取js所在的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSPost" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL: [NSURL fileURLWithPath:path]];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    
    
    [self.view addSubview:self.webView];
}

// 加载完成的代理方法
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    NSLog(@"----->>>>>>>>>>>>>");
    
    // 判断是否需要加载（仅在第一次加载）
    if (self.needLoadJSPOST) {
        // 调用使用JS发送POST请求的方法
        [self postRequestWithJS];
        // 将Flag置为NO（后面就不需要加载了）
        self.needLoadJSPOST = NO;
    }
}


// 调用JS发送POST请求
- (void)postRequestWithJS {
    // 发送POST的参数
    NSString *postData = @"\"username\":\"aaa\",\"password\":\"123\"";
    // 请求的页面地址
    NSString *urlStr = @"http://www.postexample.com";
    // 拼装成调用JavaScript的字符串
    NSString *jscript = [NSString stringWithFormat:@"post('%@', {%@});", urlStr, postData];
    
     NSLog(@">>>>>>>>>>>>>Javascript: %@", jscript);
    // 调用JS代码
    [self.webView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
        
    }];
}

@end
