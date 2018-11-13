//
//  MOBJSContextVC.h
//  TestJS
//
//  Created by 崔林豪 on 2018/11/1.
//  Copyright © 2018年 崔林豪. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//声明的协议，当前viewController必须遵守
@protocol JSObjcDelegate 

- (void)jsCallNative;
- (void)shareString:(NSString *)shareString;

@end


@interface MOBJSContextVC : UIViewController

@end

NS_ASSUME_NONNULL_END
