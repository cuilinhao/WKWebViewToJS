//
//  MOBViewController.m
//  TestJS
//
//  Created by 崔林豪 on 2018/10/24.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import "MOBViewController.h"
#import "ViewController.h"


@interface MOBViewController ()

@end

@implementation MOBViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"JS调用WKWebView";
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    
    //注入js对象Native
    //声明WKScriptMessageHandler协议
    [config.userContentController addScriptMessageHandler:self name:@"Native"];
    [config.userContentController addScriptMessageHandler:self name:@"pay"];
    
    self.myWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.myWebView.UIDelegate = self;
    [self.view addSubview:self.myWebView];
    
    [self loadBtn:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)loadBtn:(id)sender {
    
    [self _loadHtml:@"JSWKWebView"];
}


- (void)_loadHtml:(NSString *)name
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self.myWebView loadRequest:request];
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *bodyParam = (NSDictionary *)message.body;
    NSString *func = [bodyParam objectForKey:@"function"];
    
    NSLog(@"---------- MessageHandler name : %@", message.name);
    NSLog(@"---------- MessageHandler Body : %@", message.body);
    NSLog(@"---------- MessageHandler function : %@", func);
    
    if ([message.name isEqualToString:@"Native"]) {
        
        NSDictionary *parameters = [bodyParam objectForKey:@"parameters"];
        //调用本地函数1
        if ([func isEqualToString:@"addsubView"]) {
            Class tempClass = NSClassFromString([parameters objectForKey:@"view"]);
            CGRect frame = CGRectFromString([parameters objectForKey:@"frame"]);
            if (tempClass && [tempClass isSubclassOfClass:[WKWebView class]]) {
                WKWebView *tempObj = [[tempClass alloc] initWithFrame:frame ];
                tempObj.tag = [[parameters objectForKey:@"tag"] integerValue];
                
                NSURL *url = [NSURL URLWithString:[parameters objectForKey:@"urlstring"]];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [tempObj loadRequest:request];
                //[self.myWebView addSubview:tempObj];
                
            }
        }
        else if ([func isEqualToString:@"alert"])
        {//调用本地函数2
            [self showMessage:@"来自网页提示" message:[parameters description]];
        }
        else if ([func isEqualToString:@"callFunc"])
        {
            
        }
        else if([message.name isEqualToString:@"Pay"])
        {
            
        }
        else if ([message.name isEqualToString:@"dosomething"])
        {
            
        }
            
            
    }
    
    
}


- (void)showMessage:(NSString *)title message:(NSString *)message
{
    if (message == nil) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
    
}

#pragma mark - WKUIDelegate

- (void)webViewDidClose:(WKWebView *)webView
{
    NSLog(@"-----%s", __FUNCTION__);
}

//UIWebView 中这个方法是私有方法， 通过category 可以拦截alert

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"--%s", __FUNCTION__);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
         completionHandler();
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
        [self.navigationController pushViewController:vc animated:YES];

    }]];

    [self presentViewController:alert animated:YES completion:nil];

    
    
    
}


@end
