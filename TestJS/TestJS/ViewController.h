//
//  ViewController.h
//  TestJS
//
//  Created by 崔林豪 on 2018/10/24.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


@interface ViewController : UIViewController<WKUIDelegate>

@property (strong, nonatomic)  WKWebView *myWebView;
@property (strong, nonatomic) NSString  *someString;


@end

