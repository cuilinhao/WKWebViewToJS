//
//  MOBViewController.h
//  TestJS
//
//  Created by 崔林豪 on 2018/10/24.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface MOBViewController : UIViewController<WKUIDelegate,WKScriptMessageHandler>
@property (strong, nonatomic)  WKWebView *myWebView;

@end

NS_ASSUME_NONNULL_END
