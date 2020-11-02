//
//  UIViewController+Custom.m
//  Console
//
//  Created by ryotarou takanashi on 2018/10/09.
//  Copyright © 2018 Intercom, Inc. All rights reserved.
//

#import "UIViewController+Custom.h"

@implementation UIViewController (Ryotarou)

// 最前面のViewControllerを取得
+(UIViewController *)getFrontViewController{
    UIViewController * viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if([UIApplication sharedApplication].keyWindow != nil){
        UIViewController *vc = nil;
        if(viewController != nil){
            do{
                vc = [viewController presentedViewController];
                if(vc != nil){
                    if(![vc isKindOfClass:[UINavigationController class]]){
                        viewController = vc;
                    }
                }
            }while(vc != nil);
        }
    }
    return viewController;
}

@end
