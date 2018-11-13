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



#define UTILS_SCRIPT @"var base64DecodeChars = new Array(\
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,\
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,\
-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,\
52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,\
-1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,\
15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,\
-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,\
41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1);\
function utf16to8(str) {\
var out, i, len, c;\
out = \"\";\
len = str.length;\
for(i = 0; i < len; i++) {\
c = str.charCodeAt(i);\
if ((c >= 0x0001) && (c <= 0x007F)) {\
out += str.charAt(i);\
} else if (c > 0x07FF) {\
out += String.fromCharCode(0xE0 | ((c >> 12) & 0x0F));\
out += String.fromCharCode(0x80 | ((c >>  6) & 0x3F));\
out += String.fromCharCode(0x80 | ((c >>  0) & 0x3F));\
} else {\
out += String.fromCharCode(0xC0 | ((c >>  6) & 0x1F));\
out += String.fromCharCode(0x80 | ((c >>  0) & 0x3F));\
}\
}\
return out;\
}\
function utf8to16(str) {\
var out, i, len, c;\
var char2, char3;\
out = \"\";\
len = str.length;\
i = 0;\
while(i < len) {\
c = str.charCodeAt(i++);\
switch(c >> 4) {\
case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:\
out += str.charAt(i-1);\
break;\
case 12: case 13:\
char2 = str.charCodeAt(i++);\
out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));\
break;\
case 14:\
char2 = str.charCodeAt(i++);\
char3 = str.charCodeAt(i++);\
out += String.fromCharCode(((c & 0x0F) << 12) |\
((char2 & 0x3F) << 6) |\
((char3 & 0x3F) << 0));\
break;\
}\
}\
return out;\
}\
function asc2str(ascasc){\
return String.fromCharCode(ascasc);\
}\
$mob.utils = function () {};\
$mob.utils.urlEncode = function (string) {\
var str = encodeURIComponent(string);\
str = str.replace(/[!*'(),\\[\\]]/g, function (word) {\
return \"%\" + word.charCodeAt(0).toString(16);\
});\
return str;\
};\
$mob.utils.urlDecode = function (str) {\
var ret=\"\";\
for(var i=0;i<str.length;i++)\
{\
var chr = str.charAt(i);\
if(chr == \"+\")\
{\
ret+=\" \";\
}\
else if(chr==\"%\")\
{\
var asc = str.substring(i+1,i+3);\
if(parseInt(\"0x\"+asc)>0x7f)\
{\
ret+=asc2str(parseInt(\"0x\"+asc+str.substring(i+4,i+6)));\
i+=5;\
}\
else\
{\
ret+=asc2str(parseInt(\"0x\"+asc));\
i+=2;\
}\
}\
else\
{\
ret+= chr;\
}\
}\
return ret;\
};\
$mob.utils.objectToJsonString = function (obj) {\
var S = [];\
var J = null;\
var type = Object.prototype.toString.apply(obj);\
if (type === '[object Array]') {\
for (var i = 0; i < obj.length; i++) {\
S.push($mob.utils.objectToJsonString(obj[i]));\
}\
J = '[' + S.join(',') + ']';\
} else if (type === '[object Date]') {\
J = \"new Date(\" + obj.getTime() + \")\";\
} else if (type === '[object RegExp]' || type === '[object Function]') {\
J = obj.toString();\
} else if (type === '[object Object]') {\
for (var key in obj) {\
var value = $mob.utils.objectToJsonString(obj[key]);\
if (value != null) {\
S.push('\"' + key + '\":' + value);\
}\
}\
J = '{' + S.join(',') + '}';\
} else if (type === '[object String]') {\
J = '\"' + obj.replace(/\\\\/g, '\\\\\\\\').replace(/\"/g, '\\\\\"').replace(/\\n/g, '') + '\"';\
} else if (type === '[object Number]') {\
J = obj;\
} else if (type === '[object Boolean]') {\
J = obj;\
} else {\
J = 'null';\
}\
return J;\
};\
$mob.utils.trim = function (string) {\
if (Object.prototype.toString.apply(string) === '[object String]'){\
return string.replace(/(^\\s*)|(\\s*$)/g, \"\");\
}\
return null;\
};\
$mob.utils.parseUrlParameters = function (query) {\
var params = {};\
var regExp = /(([^=&]+)=([^=&]*))/ig;\
var r;\
while(r = regExp.exec(query)) {\
if (r[2] != null && r[2] != \"\") {\
params[r[2]] = r[3];\
}\
}\
return params;\
};\
$mob.utils.parseUrl = function (urlString) {\
var urlObj = {};\
var regExp = /^(\\S+):\\/\\/(([^\\s:\\/\\?\\#]+)(:(\\d+))?)?(\\/[^\\s\\?\\#]*)?(\\?([^\\s\\#]*))?(\\#([^\\s\\?]*))?/i;\
if (regExp.test(urlString)) {\
urlObj.absoluteString = urlString;\
var result = regExp.exec(urlString);\
if (result != null) {\
urlObj.scheme = result [1];\
urlObj.domain = result [3];\
urlObj.port = result [5];\
urlObj.path = result [6];\
urlObj.query = result [8];\
urlObj.fragment = result [10];\
if (urlObj.port == null || urlObj.port <= 0) {\
urlObj.port = 80;\
}\
}\
}\
return urlObj;\
};\
$mob.utils.base64Decode = function (str) {\
return decodeURIComponent(escape(atob(str)));\
};\
$mob.utils.base64Encode =  function (rawString) {\
var b64pad = '=';\
var tab = \"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/\";\
var output = \"\";\
var len = rawString.length;\
for(var i = 0; i < len; i += 3) {\
var triplet = (rawString.charCodeAt(i) << 16)\
| (i + 1 < len ? rawString.charCodeAt(i+1) << 8 : 0)\
| (i + 2 < len ? rawString.charCodeAt(i+2)      : 0);\
for(var j = 0; j < 4; j++) {\
if(i * 8 + j * 6 > rawString.length * 8) {\
output += b64pad;\
} else {\
output += tab.charAt((triplet >>> 6*(3-j)) & 0x3F);\
}\
}\
}\
return output;\
};\
$mob.utils.jsonStringToObject = function (string) {\
try {\
return eval(\"(\" + string + \")\");\
} catch (err) {\
return null;\
}\
};\
$mob.utils.getFileName = function (filePath) {\
return filePath.substr(filePath.lastIndexOf('/') + 1);\
};"

#define OLD_JS_PARSER_STARTUP_SCRIPT @"function $mob () {}\
$mob.__seqId = 0;\
$mob.__callbackFuncs = {};\
$mob.native = function () {};\
$mob.registerMethod = function (name) {\
$mob.native[name] = function () {\
var selfName = name;\
var args = [];\
for (var i = 0; i < arguments.length; i++){\
args.push(arguments[i]);\
}\
var sessionid = new Date().getTime() + $mob.__seqId;\
window.location.hash = '__action=mob_method&__name=' + $mob.utils.urlEncode(selfName) + '&__args=' + $mob.utils.urlEncode($mob.utils.objectToJsonString(args)) + '&__sessionid=' + sessionid;\
$mob.__seqId++;\
};\
};"

static char const* scriptOptQueueKey = "ScriptOptQueue";

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
#pragma mark -//执行已经存在的js代码
- (IBAction)exeFuncTouched:(id)sender {
    
//    [self.myWebView evaluateJavaScript:@"showAlert('hahaha')" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        NSLog(@"--执行已经存在的js代码-%@", result);
//    }];
    
    [self.myWebView evaluateJavaScript:@"showAlert(1);" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"--执行已经存在的js代码-%@", result);
    }];
    
    //OLD_JS_PARSER_STARTUP_SCRIPT
    
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
    
    //NSString *insertString = [NSString stringWithFormat:@"var script = document.createElement('script');""script.type = 'text/javascript';""script.text = \"function jsFunc() { ""var a=document.getElementsByTagName('body')[0];""alert('%@');""}\";""document.getElementsByTagName('head')[0].appendChild(script);", self.someString];

    NSString *insertString = [NSString stringWithFormat:
                              @"var script = document.createElement('script');"
                              "script.type = 'text/javascript';"
                              "script.text = \"function jsFunc() { "
                              "var a=document.getElementsByTagName('body')[0];"
                              "alert('%@');"
                              "}\";"
                              "document.getElementsByTagName('head')[0].appendChild(script);", self.someString];
    
    
    
    
    
    //NSLog(@"++++++++++insert string %@",insertString);

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
