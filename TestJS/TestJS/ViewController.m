//
//  ViewController.m
//  TestJS
//
//  Created by 崔林豪 on 2018/10/24.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import "ViewController.h"
#import "MOBJSPostViewController.h"


@interface ViewController ()


@end

@implementation ViewController

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height


#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.title = @"WKWebView调用JS";
    
    [self _testJS];
    
}

#pragma mark -
- (void)_testJS
{
    self.myWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0,210+40, kScreenW, kScreenH - 221) configuration:[[WKWebViewConfiguration alloc] init]];
    self.myWebView.UIDelegate = self;
    [self.view addSubview:self.myWebView];
    

    self.someString = @"iOS 8引入了一个新的框架——WebKit，之后变得好起来了。在WebKit框架中，有WKWebView可以替换UIKit的UIWebView和AppKit的WebView，而且提供了在两个平台可以一致使用的接口。WebKit框架使得开发者可以在原生App中使用Nitro来提高网页的性能和表现，Nitro就是Safari的JavaScript引擎 WKWebView 不支持JavaScriptCore的方式但提供message handler的方式为JavaScript与Native通信";
    
    [self loadTouch:nil];
}

//刷新html
- (IBAction)loadTouch:(id)sender {
    
    [self loadHtml:@"WKWebViewJS"];
    
}

//执行已经存在的js代码
- (IBAction)exeFuncTouched:(id)sender {
    
    [self.myWebView evaluateJavaScript:@"showAlert('hahaha')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"--执行已经存在的js代码-%@", result);
    }];
}

//自带标签getElementsByTagName插入html

- (IBAction)insertHtmlTouch:(id)sender {
    //替换第一个P元素内容
    NSString *tempString = [NSString stringWithFormat:@"document.getElementsByTagName('p')[0].innerHTML='%@';", self.someString];
    [self.myWebView evaluateJavaScript:tempString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"--自带标签getElementsByTagName插入html-%@", result);
    }];
}

//getElementsByName 根据标签名称获取定位元素 填input
- (IBAction)inputButton:(id)sender {
    NSString *tempString = [NSString stringWithFormat:@"document.getElementsByName('wd')[0].value='%@';", self.someString];
    [self.myWebView evaluateJavaScript:tempString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"--根据标签名称获取定位元素 填input-%@", result);
    }];
}

//getElementById插入html
- (IBAction)insertDivHtml:(id)sender {
    
    //替换第id为idtest的DIV元素内容
    NSString *tempString2 = [NSString stringWithFormat:@"document.getElementById('idTest').innerHTML='%@';", self.someString];
    [self.myWebView evaluateJavaScript:tempString2
                     completionHandler:^(id _Nullable rr, NSError * _Nullable error) {
        NSLog(@"--自带标签getElementsByTagName插入html->>>>>>>>>>>>>>>>>>>>>>>>%@", rr);
    }];
    
}

//插入JS并且执行
- (IBAction)insertJS:(id)sender {
    
    NSString *insertString = [NSString stringWithFormat:@"var script = document.createElement('script');""script.type = 'text/javascript';""script.text = \"function jsFunc() { ""var a=document.getElementsByTagName('body')[0];""alert('%@');""}\";""document.getElementsByTagName('head')[0].appendChild(script);", self.someString];

//    NSString *insertString = [NSString stringWithFormat:
//                              @"var script = document.createElement('script');"
//                              "script.type = 'text/javascript';"
//                              "script.text = \"function jsFunc() { "
//                              "var a=document.getElementsByTagName('body')[0];"
//                              "alert('%@');"
//                              "}\";"
//                              "document.getElementsByTagName('head')[0].appendChild(script);", self.someString];
    
    NSLog(@"++++++++++insert string %@",insertString);

    [self.myWebView evaluateJavaScript:insertString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"+++++++1111111+++insert string %@",result);
    }];

    [self.myWebView evaluateJavaScript:@"jsFunc();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"++++22222++++++insert string %@",result);
    }];
    
    
    
    
}


//修改字体
- (IBAction)fontTouched:(id)sender {
    
    NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('p')[0].style.fontSize='%@';",@"19px"];
    [self.myWebView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"++++修改字体++++++ %@",result);
    }];
    
}

//替换图片地址
- (IBAction)replaceImgSrc:(id)sender {
    NSString *str = [NSString stringWithFormat:@"document.getElementsByTagName('img')[0].src = '%@';",@"light_advice.png"];
    [self.myWebView evaluateJavaScript:str completionHandler:^(id _Nullable result, NSError * _Nullable error) {
         NSLog(@"++++替换图片地址++++++ %@",result);
    }];
    
}

//submit
- (IBAction)submitTouched:(id)sender {
}

#pragma mark - private

- (void)loadHtml:(NSString *)name
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:request];
    
}


#pragma mark - WKUIDelegate

- (void)webViewDidClose:(WKWebView *)webView
{
    NSLog(@">>>>>>>>>%s\n", __FUNCTION__);
    
}

//UIWebView 中这个方法时私有方法 通过category可以拦截alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"++++++++%s\n", __FUNCTION__);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"1024-1024" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        MOBJSPostViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MOBJSPostViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}



@end
