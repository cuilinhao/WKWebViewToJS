//
//  MOBJSContextVC.m
//  TestJS
//
//  Created by 崔林豪 on 2018/11/1.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import "MOBJSContextVC.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIWebView.h>


@interface MOBJSContextVC ()<JSExport, UIWebViewDelegate>

@property (nonatomic, strong) JSContext *jsContext;

@property (nonatomic, strong) UIWebView *webView;



@end

@implementation MOBJSContextVC

/*
 JSContext --- 在OC中创建JavaScript运行的上下文环境
  - (instancetype)init; // 创建JSContext对象，获得JavaScript运行的上下文环境
 
 // 在特定的对象空间上创建JSContext对象，获得JavaScript运行的上下文环境
 - (instancetype)initWithVirtualMachine:(JSVirtualMachine *)virtualMachine;
 
 // 运行一段js代码，输出结果为JSValue类型
 - (JSValue *)evaluateScript:(NSString *)script;
 
 // iOS 8.0以后可以调用此方法
 - (JSValue *)evaluateScript:(NSString *)script withSourceURL:(NSURL *)sourceURL NS_AVAILABLE(10_10, 8_0);

 // 获取当前正在运行的JavaScript上下文环境
 + (JSContext *)currentContext;
 
 // 返回结果当前执行的js函数 function () { [native code] } ，iOS 8.0以后可以调用此方法
 + (JSValue *)currentCallee NS_AVAILABLE(10_10, 8_0);
 
 // 返回结果当前方法的调用者[object Window]
 + (JSValue *)currentThis;
 
 // 返回结果为当前被调用方法的参数
 + (NSArray *)currentArguments;
 
 // js的全局变量 [object Window]
 @property (readonly, strong) JSValue *globalObject;
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 JSValue --- JavaScript中的变量和方法，可以转成OC数据类型,每个JSValue都和JSContext相关联并且强引用context
 
 //此方法会转换self为JS对象，但是self中必须实现指定的方法和协议
 + (JSValue *)valueWithObject:(id)value inContext:(JSContext *)context;
 
 // 在context创建BOOL的JS变量
 + (JSValue *)valueWithBool:(BOOL)value inContext:(JSContext *)context;
 
 // 将JS变量转换成OC中的BOOL类型
 - (BOOL)toBool;
 
 // 修改JS对象的属性的值
 - (void)setValue:(id)value forProperty:(NSString *)property;
 
 // JS中是否有这个对象
 @property (readonly) BOOL isUndefined;
 
 // 比较两个JS对象是否相等
 - (BOOL)isEqualToObject:(id)value;
 
 // 调用者JSValue为JS中的方法，arguments为参数，执行调用者JSValue，并传递参数arguments,@[@"a",@"b"@"c"]
 - (JSValue *)callWithArguments:(NSArray *)arguments;
 
 // 调用者JSValue为JS中的全局对象名称，method为全局对象的方法名称，arguments为参数
 - (JSValue *)invokeMethod:(NSString *)method withArguments:(NSArray *)arguments;
 
 // JS中的结构体类型转换为OC
 + (JSValue *)valueWithPoint:(CGPoint)point inContext:(JSContext *)context;
 
 >>>>>>>>>>>>>>>>>>>>>>>>>
 JSExport --- JS调用OC中的方法和属性写在继承自JSExport的协议当中，OC对象实现自定义的协议
 
 JSExportAs (textFunction,- (void) ocTestFunction:(NSNumber *)value sec:(NSNumber *)number);
 JSManagedValue --- JS和OC对象的内存管理辅助对象,主要用来保存JSValue对象,解决OC对象中存储js的值，导致的循环引用问题
 
 
 JSManagedValue本身只弱引用js值，需要调用JSVirtualMachine的addManagedReference:withOwner:把它添加到JSVirtualMachine中，这样如果JavaScript能够找到该JSValue的Objective-C owner，该JSValue的引用就不会被释放。
 
 
 JSManagedValue *_jsManagedValue = [JSManagedValue managedValueWithValue:jsValue];
 [_context.virtualMachine addManagedReference:_jsManagedValue];
 
 
 JSVirtualMachine --- JS运行的虚拟机，有独立的堆空间和垃圾回收机制，运行在不同虚拟机环境的JSContext可以通过此类通信。
 
 作者：Kasign
 链接：https://www.jianshu.com/p/459cb886e863
 來源：简书
 简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
 
 */

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 375, 300)];
    _webView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_webView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSContext" ofType:@"html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
    
    _webView.delegate = self;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
     //[self _testSomeJsThings];
    
    [self _addContexttoJS];
}

#pragma mark - 想js中添加东西 delegate
- (void)_addContexttoJS
{
    // 创建JavaScript执行环境(上下文)
    //JSContext *context = [[JSContext alloc] init];
    // 可以将一个block传给JavaScript上下文
    // 它会被转换成一个JavaScript中的函数
    
    self.jsContext[@"factorial"] = ^(int x) {
        double result = 1.0;
        for (; x > 1; x--) {
            result *= x;
        }
        return result;
    };
    // 执行求阶乘的函数
    [self.jsContext evaluateScript:@"var num = factorial(5);"];
    JSValue *num = self.jsContext[@"num"];
    NSLog(@">>>>>>>>>>.5! = %@", num);    // 5! = 120
    
}

#pragma mark - 在本地生成js方法，供js调用
- (void)_doSomeJsThings
{
    self.jsContext = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"---出现异常， 异常信息: %@", exception);
    };
    
    //OC 调用js
    JSValue *jsObj = self.jsContext[@"globalObject"];
    
    //jsObject执行其方法nativeCallJS
    //调用JS中方法“nativeCallJS”, 并且传参数"hello world", returnValue 是调用之后的返回值，可能为nil
    JSValue * returnValue = [jsObj invokeMethod:@"nativeCallJS" withArguments:@[@"hello world"]];

    NSLog(@"----returnValue--%@", returnValue);
    
    /*
     //此方法会转换self为JS对象，但是self中必须实现指定的方法和协议
     + (JSValue *)valueWithObject:(id)value inContext:(JSContext *)context;
     */
    
    JSValue *jsCallNative = [JSValue valueWithObject:self inContext:self.jsContext];
    self.jsContext[@"NativeObject"] = jsCallNative;
    
    //------
    //oc调用js
    JSValue * jsObj2 = self.jsContext[@"globalObject"];//拿到JS中已经存在的对象
    //为jsObj对应的方法提供方法实现
    jsObj2[@"creatJSMethod"] = ^(NSString * parameter){
        NSLog(@">>>>>>>>>.方法生成成功：%@",parameter);
    };
    
    
    
}

- (void)jsCallNative
{//在本地生成js方法，供js调用
    
    JSValue *currentThis = [JSContext currentThis];
    JSValue *currentCallee = [JSContext currentCallee];
    NSArray *currentParamers = [JSContext currentArguments];
    dispatch_async(dispatch_get_main_queue(), ^{
        /**
         *  js调起OC代码，代码在子线程，更新OC中的UI，需要回到主线程
         */
    });
    NSLog(@"--------currentThis is %@",[currentThis toString]);
    NSLog(@"-----currentCallee is %@",[currentCallee toString]);
    NSLog(@"--------currentParamers is %@",currentParamers);
    
}

- (void)shareString:(NSString *)shareString
{//在本地生成js方法，供js调用
    JSValue *currentThis = [JSContext currentThis];
    JSValue *currentCallee = [JSContext currentCallee];
    NSArray *currentParamers = [JSContext currentArguments];
    dispatch_async(dispatch_get_main_queue(), ^{
        /**
         *  js调起OC代码，代码在子线程，更新OC中的UI，需要回到主线程
         */
        NSLog(@"js传过来：%@",shareString);
    });
    NSLog(@"----JS paramer is %@",shareString);
    NSLog(@"----currentThis is %@",[currentThis toString]);
    NSLog(@"---currentCallee is %@",[currentCallee toString]);
    NSLog(@"----currentParamers is %@",currentParamers);
    
    
}

#pragma mark - UIWebView delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self _doSomeJsThings];
    
}

#pragma mark - 在本地生成js方法，供js调用
- (void)_testSomeJsThings
{
    self.jsContext = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"---出现异常， 异常信息: %@", exception);
        
    };
    
    //OC 调用js
    JSValue *nativeCallJS = self.jsContext[@"nativeCallJS"];
    //调用了js方法"nativeCallJS" 且传参数@"hello world"
    [nativeCallJS callWithArguments:@[@"hello world"]];
    
    //在本地生成js方法，供js调用
    //生成native的js方法，方法名：@"jsCallNative",js可直接调用此方法
    self.jsContext[@"jsCallNative"] = ^(NSString *paramer){
        JSValue *currentThis = [JSContext currentThis];
        JSValue *currentCallee = [JSContext currentCallee];
        NSArray *currentParamers = [JSContext currentArguments];
        dispatch_async(dispatch_get_main_queue(), ^{
            //js 调用OC代码， 代码在子线程， 更新OC中的UI 需要回到主线程
            NSLog(@"---js传过来：%@", paramer);
        });
        
        NSLog(@"----paramer is  %@ ", paramer);
        NSLog(@"----currentThis is  %@ ", [currentThis toString]);
        NSLog(@"----currentCallee is  %@ ", [currentCallee toString]);
        NSLog(@"----currentParamers is  %@ ", currentParamers );
    };
    
}



@end
