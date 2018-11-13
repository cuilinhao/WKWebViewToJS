//
//  MOBDynamicViewController.m
//  TestJS
//
//  Created by 崔林豪 on 2018/11/13.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import "MOBDynamicViewController.h"

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/message.h>

//链接：https://www.jianshu.com/p/253e76a74b38

@interface MOBDynamicViewController ()<WKNavigationDelegate,WKScriptMessageHandler, WKUIDelegate>

@property (nonatomic,strong) WKWebView *webView;

@property (nonatomic, strong) dispatch_semaphore_t group;
@property (nonatomic, strong) dispatch_queue_t queue;


@end

@implementation MOBDynamicViewController


#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor purpleColor];
    //[self setupWKWebView];
    [self creatWebView];
}


//创建webView
-(void)creatWebView
{
    self.group = dispatch_semaphore_create(0);
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    //初始化偏好设置属性：preferences
    config.preferences = [WKPreferences new];
    //The minimum font size in points default is 0;
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //通过JS与webView内容交互
    config.userContentController = [WKUserContentController new];
    // 注入JS对象名称senderModel，当JS通过senderModel来调用时，我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"senderModel"];
    [config.userContentController addScriptMessageHandler:self name:@"call"];
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, 375, 300+40) configuration:config];
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"WKWebViewText" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:path]];
    [self.view addSubview:self.webView];
    
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    
    [self.webView evaluateJavaScript:@"$mob = function () {}; $mob.native = function () {};" completionHandler:nil];
    
    
    //MARK:- >>>>>>>>>>>>>>>>注册>>>>>>>>>>>>>>>>
    //MARK:- >>>>>>>>>>>>>>>>动态向js中添加方法>>>>>>>>>>>>>>>>
    
    [self.webView evaluateJavaScript:
     @"$mob.native.base64Decode = function ()\
     {\
     var args = arguments;\
     var type = \"Testbridge\";\
     var name = \"$mob.native.base64Decode\";\
     var data = {\"args\":args};\
     var payload = {\"type\":type, \"functionName\":name, \"data\":args};\
     var res = prompt(JSON.stringify(payload));\
     return res;\
     }"
                   completionHandler:nil];
    
    
    //    [self.webView evaluateJavaScript:
    //     @"$mob.native.base64Decode = function ()\
    //     {\
    //     var args = arguments;\
    //     var type = \"Testbridge\";\
    //     var name = \"$mob.native.base64Decode\";\
    //     var data = {\"args\":args[0]};\
    //     var payload = {\"type\":type, \"functionName\":name, \"data\":data};\
    //     var res = prompt(JSON.stringify(payload));\
    //     return res;\
    //     }"
    //                       completionHandler:nil];
    
    
}



//MARK:- -------------调用-------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /*
     [self.webView evaluateJavaScript:@"callJsAlert()" completionHandler:^(id _Nullable rr, NSError * _Nullable error) {
     NSLog(@"-----touchesBegan---%@", rr);
     }];
     */
    
    [self.webView evaluateJavaScript:@"$mob.native.base64Decode('www','eee');" completionHandler:^(id _Nullable rr, NSError * _Nullable error) {
        NSLog(@"-----%@", rr);
    }];
    
}

- (IBAction)insert:(id)sender
{
    
    
    //self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, 375, 300+40) configuration:config];
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:path]];
    //    [self.view addSubview:self.webView];
    
    
}

#pragma mark - WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //这里可以通过name处理多组交互
    if ([message.name isEqualToString:@"senderModel"]) {
        //body只支持NSNumber, NSString, NSDate, NSArray,NSDictionary 和 NSNull类型
        NSLog(@">>>>>>>>>>>>>>>>>%@",message.body);
    }
    
    if ([message.name isEqualToString:@"call"])
    {
        NSDictionary *dic = message.body;
        NSString *fun = [dic objectForKey:@"funName"];
        if ([fun isEqualToString:@"base64Decode"])
        {
            // id args = [dic objectForKey:@"args"];
            NSLog(@"+++++++++++++++++++");
            // [_webView evaluateJavaScript:@"result = 1" completionHandler:nil];
        }
    }
    
    
}


- (void)dealloc
{
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"senderModel"];
    
}

#pragma mark = WKNavigationDelegate
//在发送请求之前，决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *hostname = navigationAction.request.URL.host.lowercaseString;
    NSLog(@"%@",hostname);
    
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated
        && ![hostname containsString:@".baidu.com"]) {
        
        // 对于跨域，需要手动跳转
        //[[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        //self.progressView.alpha = 1.0;
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
    
}
//在响应完成时，调用的方法。如果设置为不允许响应，web内容就不会传过来

-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(WKNavigationResponsePolicyAllow);
}
//接收到服务器跳转请求之后调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}

//开始加载时调用
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
//当内容开始返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
//页面加载完成之后调用
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"title:%@",webView.title);
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    
}

#pragma mark WKUIDelegate

//alert 警告框
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"调用alert提示框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"alert message:%@",message);
    
}

//confirm 确认框
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认框" message:@"调用confirm提示框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"confirm message:%@", message);
    
}

/*
 @"$mob.native.base64Decode = function ()\
 {\
 var args = arguments;\
 var type = \"SJbridge\";\
 var name = \"base64Decode\";\
 var data = {\"args\":args}\
 var payload = {type: type, functionName: name, data: data};\
 var res = prompt(JSON.stringify (payload));\
 return res;\
 }"
 */
#pragma mark - --------获取数据 ---------
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSData *dataFromString = [prompt dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if (dataFromString)
    {
        //NSData *jsonData = [dataFromString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:dataFromString options:NSJSONReadingMutableContainers error:nil];
        NSString *type = [payload objectForKey:@"type"];
        if ([type isEqualToString:@"Testbridge"])
        {
            NSString *functionName = [payload objectForKey:@"functionName"];
            
            if ([functionName isEqualToString:@"$mob.native.base64Decode"])
            {
                // 1.解码bo
                // 2.解码结果回调
                
                //NSError *error;
                NSDictionary *ploadData = [payload objectForKey:@"data"];
                NSLog(@"---data--000000->>>>>>>--%@", ploadData);
                
                NSString *jsonString = ploadData[@"0"];
                NSString *str = [self dataByBase64DecodeString:jsonString];
                NSLog(@"------------返回-----%@", jsonString);
                NSLog(@"-----返回---%@", str);
                //completionHandler(@"我是回调~ .....");
                completionHandler(jsonString);
            }
            //return;
        }
        else
        {
            
        }
    }
    //    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入框" message:@"调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    //    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    //        textField.textColor = [UIColor blackColor];
    //    }];
    //
    //    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    //        completionHandler([[alert.textFields lastObject] text]);
    //    }]];
    //
    //    [self presentViewController:alert animated:YES completion:NULL];
}


//字典转json格式字符串：
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (NSString *)dataByBase64DecodeString:(NSString *)string
{
    
    if (![string isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    
    NSData *data = [[NSData alloc] initWithBase64Encoding:string];
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
    
}


//- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
//{
//    NSLog(@">>>>>>>>>>>>>>>>%@",message.body);//message.body这里面内容是js里传过来的参数
//    //message.name这个是注入的JS对象名称 "JSObjec"
//    if ([message.name isEqualToString:@"JSObjec"]) {
//        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
//        // NSDictionary, and NSNull类型
//        // 此处填写相应的逻辑代码
//        NSLog(@">>>>>>>----------->>>>>>>>>%@",message.body);
//    }
//}


@end
