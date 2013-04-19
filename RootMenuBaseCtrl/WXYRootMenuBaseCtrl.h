//
//  WXYRootMenuBaseCtrl.h
//  RootMenuCtrl
//
//  Created by weixianyu on 3/27/13.
//  Copyright (c) 2013 weixianyu. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    WXYMenuPanDirectionLeft = 0,
    WXYMenuPanDirectionRight,
} WXYMenuPanDirection;

typedef enum {
    WXYMenuPanCompletionLeft = 0,
    WXYMenuPanCompletionRight,
    WXYMenuPanCompletionRoot,
} WXYMenuPanCompletion;



@protocol WXYMenuControllerDelegate;
@interface WXYRootMenuBaseCtrl : UIViewController<UIGestureRecognizerDelegate>
{
    id _tap;
    id _pan;
    
    CGFloat _panOriginX;
    CGPoint _panVelocity;
    WXYMenuPanDirection _panDirection;
    
    struct
    {
        unsigned int respondsToWillShowViewController:1;
        unsigned int showingLeftView:1;
        unsigned int showingRightView:1;
        unsigned int canShowRight:1;
        unsigned int canShowLeft:1;
    } _menuFlags;
}

- (id)initWithRootViewController:(UIViewController*)controller;

@property(nonatomic,assign) id <WXYMenuControllerDelegate> delegate;

@property(nonatomic,strong) UIViewController *leftViewController;
@property(nonatomic,strong) UIViewController *rightViewController;
@property(nonatomic,strong) UIViewController *rootViewController;

@property(nonatomic,readonly) UITapGestureRecognizer *tap;
@property(nonatomic,readonly) UIPanGestureRecognizer *pan;

- (void)setRootController:(UIViewController *)controller animated:(BOOL)animated; // used to push a new controller on the stack
- (void)showRootController:(BOOL)animated; // reset to "home" view controller
- (void)showRightController:(BOOL)animated;  // show right
- (void)showLeftController:(BOOL)animated;  // show left

@end



@protocol WXYMenuControllerDelegate
- (void)menuController:(WXYRootMenuBaseCtrl*)controller willShowViewController:(UIViewController*)controller;
@end
