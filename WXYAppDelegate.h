//
//  WXYAppDelegate.h
//  RootMenuCtrl
//
//  Created by weixianyu on 3/27/13.
//  Copyright (c) 2013 weixianyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYRootMenuBaseCtrl;

@interface WXYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) WXYRootMenuBaseCtrl *menuController;
@property (retain, nonatomic) UINavigationController *topNavCtrl;
@property (retain, nonatomic) UIImageView *topImageView;
@property (retain, nonatomic) UIView*backgroudView;
@property (retain, nonatomic) NSMutableArray*imageArray;
@property (retain, nonatomic) UIView*currentView;
  @property (assign, nonatomic) float lastInstance;
-(void)screenShots;
- (void)configGesstureInfo:(UIView*)view;
@end
