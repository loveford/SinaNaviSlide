//
//  WXYRootMenuBaseCtrl.m
//  RootMenuCtrl
//
//  Created by weixianyu on 3/27/13.
//  Copyright (c) 2013 weixianyu. All rights reserved.
//

#import "WXYRootMenuBaseCtrl.h"
#import "QuartzCore/QuartzCore.h"


#define kMenuFullWidth 320.0f
#define kMenuDisplayedWidth 320.0f
#define kMenuOverlayWidth (self.view.bounds.size.width - kMenuDisplayedWidth)
#define kMenuBounceOffset 10.0f
#define kMenuBounceDuration .3f
#define kMenuSlideDuration .3f


@interface WXYRootMenuBaseCtrl ()
  - (void)showShadow:(BOOL)val;
@end

@implementation WXYRootMenuBaseCtrl
@synthesize delegate;

@synthesize leftViewController=_left;
@synthesize rightViewController=_right;
@synthesize rootViewController=_root;

@synthesize tap=_tap;
@synthesize pan=_pan;

//自定义函数，用以保持对顶层的viewCtrl的引用
- (id)initWithRootViewController:(UIViewController*)controller {
    if ((self = [super init])) {
        _root = controller;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setRootViewController:_root]; // reset root
    
    if (!_tap) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tap.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.view addGestureRecognizer:tap];
        [tap setEnabled:NO];
        _tap = tap;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -支持旋转操作，实现系统函数，处理旋转参数
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [_root shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (_root) {
        
        [_root willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        
        UIView *view = _root.view;
        
        if (_menuFlags.showingRightView) {
            
            view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            
        } else if (_menuFlags.showingLeftView) {
            
            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
        } else {
            
            view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            
        }
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (_root) {
        
        [_root didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        
        CGRect frame = self.view.bounds;
        if (_menuFlags.showingLeftView) {
            frame.origin.x = frame.size.width - kMenuOverlayWidth;
        } else if (_menuFlags.showingRightView) {
            frame.origin.x = -(frame.size.width - kMenuOverlayWidth);
        }
        _root.view.frame = frame;
        _root.view.autoresizingMask = self.view.autoresizingMask;
        
        [self showShadow:(_root.view.layer.shadowOpacity!=0.0f)];
        
    }
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (_root) {
        [_root willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    
}


#pragma mark - GestureRecognizers
//处理滑动手势
- (void)pan:(UIPanGestureRecognizer*)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        //判断滑动的方向
        [self showShadow:YES];
        _panOriginX = self.view.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
        if([gesture velocityInView:self.view].x > 0)
        {
            _panDirection = WXYMenuPanDirectionRight;
        }
        else
        {
            _panDirection = WXYMenuPanDirectionLeft;
        }
        
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        //获取在滑动过程中向左或者向右，拖动的速度，向量单位，velocityInView。
        CGPoint velocity = [gesture velocityInView:self.view];
        if((velocity.x*_panVelocity.x + velocity.y*_panVelocity.y) < 0)
        {
            _panDirection = (_panDirection == WXYMenuPanDirectionRight) ? WXYMenuPanDirectionLeft : WXYMenuPanDirectionRight;
        }
        
        
        _panVelocity = velocity;
        //获取在滑动过程中拖动的距离，translationInView
        CGPoint translation = [gesture translationInView:self.view];
        CGRect frame = _root.view.frame;
        frame.origin.x = _panOriginX + translation.x;
        
        //向左滑动
        if (frame.origin.x > 0.0f && !_menuFlags.showingLeftView)
        {
            
            if(_menuFlags.showingRightView)
            {
                _menuFlags.showingRightView = NO;
                [self.rightViewController.view removeFromSuperview];
            }
            
            if (_menuFlags.canShowLeft)
            {
                
                _menuFlags.showingLeftView = YES;
                CGRect frame = self.view.bounds;
				frame.size.width = kMenuFullWidth;
                self.leftViewController.view.frame = frame;
                [self.view insertSubview:self.leftViewController.view atIndex:0];
                
            }
            else
            {
                frame.origin.x = 0.0f; // ignore right view if it's not set
            }
            
        }
        //向右滑动
        else if (frame.origin.x < 0.0f && !_menuFlags.showingRightView)
        {
            
            if(_menuFlags.showingLeftView)
            {
                _menuFlags.showingLeftView = NO;
                [self.leftViewController.view removeFromSuperview];
            }
            
            if (_menuFlags.canShowRight)
            {
                
                _menuFlags.showingRightView = YES;
                CGRect frame = self.view.bounds;
				frame.origin.x += frame.size.width - kMenuFullWidth;
				frame.size.width = kMenuFullWidth;
                self.rightViewController.view.frame = frame;
                [self.view insertSubview:self.rightViewController.view atIndex:0];
                
            }
            else
            {
                frame.origin.x = 0.0f; // ignore left view if it's not set
            }
            
        }
        
        _root.view.frame = frame;
        
    }
    //手势操作完成
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        
        //  Finishing moving to left, right or root view with current pan velocity
        [self.view setUserInteractionEnabled:NO];
        
        WXYMenuPanCompletion completion = WXYMenuPanCompletionRoot; // by default animate back to the root
        
        if (_panDirection == WXYMenuPanDirectionRight && _menuFlags.showingLeftView)
        {
            completion = WXYMenuPanCompletionLeft;
        }
        else if(_panDirection == WXYMenuPanDirectionLeft && _menuFlags.showingRightView)
        {
            completion = WXYMenuPanCompletionRight;
        }
        
        CGPoint velocity = [gesture velocityInView:self.view];
        if (velocity.x < 0.0f)
        {
            velocity.x *= -1.0f;
        }
        BOOL bounce = (velocity.x > 800);
        CGFloat originX = _root.view.frame.origin.x;
        CGFloat width = _root.view.frame.size.width;
        CGFloat span = (width - kMenuOverlayWidth);
        CGFloat duration = kMenuSlideDuration; // default duration with 0 velocity
        
        //根据已经滑动的距离计算动画的时间
        if (bounce)
        {
            duration = (span / velocity.x); // bouncing we'll use the current velocity to determine duration
        }
        else
        {
            duration = ((span - originX) / span) * duration; // user just moved a little, use the defult duration, otherwise it would be too slow
        }
        
        //设置CA动画
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (completion == WXYMenuPanCompletionLeft)
            {
                [self showLeftController:NO];
            }
            else if (completion == WXYMenuPanCompletionRight)
            {
                [self showRightController:NO];
            }
            else
            {
                [self showRootController:NO];
            }
            [_root.view.layer removeAllAnimations];
            [self.view setUserInteractionEnabled:YES];
        }];
        
        CGPoint pos = _root.view.layer.position;
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        
        NSMutableArray *keyTimes = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounce ? 3 : 2];
        
        [values addObject:[NSValue valueWithCGPoint:pos]];
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [keyTimes addObject:[NSNumber numberWithFloat:0.0f]];
        if (bounce)
        {
            
            duration += kMenuBounceDuration;
            [keyTimes addObject:[NSNumber numberWithFloat:1.0f - ( kMenuBounceDuration / duration)]];
            if (completion == WXYMenuPanCompletionLeft) {
                
                [values addObject:[NSValue valueWithCGPoint:CGPointMake(((width/2) + span) + kMenuBounceOffset, pos.y)]];
                
            } else if (completion == WXYMenuPanCompletionRight) {
                
                [values addObject:[NSValue valueWithCGPoint:CGPointMake(-((width/2) - (kMenuOverlayWidth-kMenuBounceOffset)), pos.y)]];
                
            } else {
                
                // depending on which way we're panning add a bounce offset
                if (_panDirection == WXYMenuPanDirectionLeft) {
                    [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) - kMenuBounceOffset, pos.y)]];
                } else {
                    [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) + kMenuBounceOffset, pos.y)]];
                }
                
            }
            
            [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
            
        }
        if (completion == WXYMenuPanCompletionLeft) {
            [values addObject:[NSValue valueWithCGPoint:CGPointMake((width/2) + span, pos.y)]];
        } else if (completion == WXYMenuPanCompletionRight) {
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(-((width/2) - kMenuOverlayWidth), pos.y)]];
        } else {
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(width/2, pos.y)]];
        }
        
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [keyTimes addObject:[NSNumber numberWithFloat:1.0f]];
        
        animation.timingFunctions = timingFunctions;
        animation.keyTimes = keyTimes;
        //animation.calculationMode = @"cubic";
        animation.values = values;
        animation.duration = duration;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [_root.view.layer addAnimation:animation forKey:nil];
        [CATransaction commit];
        
    }
    
}

- (void)tap:(UITapGestureRecognizer*)gesture {
    
    [gesture setEnabled:NO];
    [self showRootController:YES];
    
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    // Check for horizontal pan gesture
    if (gestureRecognizer == _pan) {
        
        UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)gestureRecognizer;
        CGPoint translation = [panGesture translationInView:self.view];
        
        if ([panGesture velocityInView:self.view].x < 600 && sqrt(translation.x * translation.x) / sqrt(translation.y * translation.y) > 1) {
            return YES;
        }
        
        return NO;
    }
    
    if (gestureRecognizer == _tap) {
        
        if (_root && (_menuFlags.showingRightView || _menuFlags.showingLeftView)) {
            return CGRectContainsPoint(_root.view.frame, [gestureRecognizer locationInView:self.view]);
        }
        
        return NO;
        
    }
    
    return YES;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer==_tap) {
        return YES;
    }
    return NO;
}


#pragma Internal Nav Handling

- (void)resetNavButtons {
    if (!_root) return;
    
    UIViewController *topController = nil;
    if ([_root isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navController = (UINavigationController*)_root;
        if ([[navController viewControllers] count] > 0) {
            topController = [[navController viewControllers] objectAtIndex:0];
        }
        
    } else if ([_root isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabController = (UITabBarController*)_root;
        topController = [tabController selectedViewController];
        
    } else {
        
        topController = _root;
        
    }
    
    if (_menuFlags.canShowLeft) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showLeft:)];
        topController.navigationItem.leftBarButtonItem = button;
    } else {
        topController.navigationItem.leftBarButtonItem = nil;
    }
    
    if (_menuFlags.canShowRight) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon.png"] style:UIBarButtonItemStyleBordered  target:self action:@selector(showRight:)];
        topController.navigationItem.rightBarButtonItem = button;
    } else {
        topController.navigationItem.rightBarButtonItem = nil;
    }
    
}

- (void)showShadow:(BOOL)val {
    if (!_root) return;
    
    _root.view.layer.shadowOpacity = val ? 0.8f : 0.0f;
    if (val) {
        _root.view.layer.cornerRadius = 4.0f;
        _root.view.layer.shadowOffset = CGSizeZero;
        _root.view.layer.shadowRadius = 4.0f;
        _root.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    }
    
}

- (void)showRootController:(BOOL)animated {
    
    [_tap setEnabled:NO];
    _root.view.userInteractionEnabled = YES;
    
    CGRect frame = _root.view.frame;
    frame.origin.x = 0.0f;
    
    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated) {
        [UIView setAnimationsEnabled:NO];
    }
    
    [UIView animateWithDuration:.3 animations:^{
        
        _root.view.frame = frame;
        
    } completion:^(BOOL finished) {
        
        if (_left && _left.view.superview) {
            [_left.view removeFromSuperview];
        }
        
        if (_right && _right.view.superview) {
            [_right.view removeFromSuperview];
        }
        
        _menuFlags.showingLeftView = NO;
        _menuFlags.showingRightView = NO;
        
        [self showShadow:NO];
        
    }];
    
    if (!animated) {
        [UIView setAnimationsEnabled:_enabled];
    }
    
}

- (void)showLeftController:(BOOL)animated
{
    if (!_menuFlags.canShowLeft) return;
    
    if (_right && _right.view.superview)
    {
        [_right.view removeFromSuperview];
        _menuFlags.showingRightView = NO;
    }
    
    if (_menuFlags.respondsToWillShowViewController)
    {
        [self.delegate menuController:self willShowViewController:self.leftViewController];
    }
    _menuFlags.showingLeftView = YES;
    [self showShadow:YES];
    
    UIView *view = self.leftViewController.view;
	CGRect frame = self.view.bounds;
	frame.size.width = kMenuFullWidth;
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    [self.leftViewController viewWillAppear:animated];
    
    frame = _root.view.frame;
    frame.origin.x = CGRectGetMaxX(view.frame) - (kMenuFullWidth - kMenuDisplayedWidth);
    
    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated)
    {
        [UIView setAnimationsEnabled:NO];
    }
    
    _root.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:^{
        _root.view.frame = frame;
    } completion:^(BOOL finished)
    {
        [_tap setEnabled:YES];
    }];
    
    if (!animated)
    {
        [UIView setAnimationsEnabled:_enabled];
    }
    
}

- (void)showRightController:(BOOL)animated {
    if (!_menuFlags.canShowRight) return;
    
    if (_left && _left.view.superview) {
        [_left.view removeFromSuperview];
        _menuFlags.showingLeftView = NO;
    }
    
    if (_menuFlags.respondsToWillShowViewController) {
        [self.delegate menuController:self willShowViewController:self.rightViewController];
    }
    _menuFlags.showingRightView = YES;
    [self showShadow:YES];
    
    UIView *view = self.rightViewController.view;
    CGRect frame = self.view.bounds;
	frame.origin.x += frame.size.width - kMenuFullWidth;
	frame.size.width = kMenuFullWidth;
    view.frame = frame;
    [self.view insertSubview:view atIndex:0];
    
    frame = _root.view.frame;
    frame.origin.x = -(frame.size.width - kMenuOverlayWidth);
    
    BOOL _enabled = [UIView areAnimationsEnabled];
    if (!animated) {
        [UIView setAnimationsEnabled:NO];
    }
    
    _root.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:^{
        _root.view.frame = frame;
    } completion:^(BOOL finished) {
        [_tap setEnabled:YES];
    }];
    
    if (!animated) {
        [UIView setAnimationsEnabled:_enabled];
    }
}


#pragma mark Setters

- (void)setDelegate:(id<WXYMenuControllerDelegate>)val {
    delegate = val;
    _menuFlags.respondsToWillShowViewController = [(id)self.delegate respondsToSelector:@selector(menuController:willShowViewController:)];
}

- (void)setRightViewController:(UIViewController *)rightController {
    _right = rightController;
    _menuFlags.canShowRight = (_right!=nil);
    [self resetNavButtons];
}

- (void)setLeftViewController:(UIViewController *)leftController {
    _left = leftController;
    _menuFlags.canShowLeft = (_left!=nil);
    [self resetNavButtons];
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    UIViewController *tempRoot = _root;
    _root = rootViewController;
    
    if (_root) {
        
        if (tempRoot) {
            [tempRoot.view removeFromSuperview];
            tempRoot = nil;
        }
        
        UIView *view = _root.view;
        view.frame = self.view.bounds;
        [self.view addSubview:view];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = (id<UIGestureRecognizerDelegate>)self;
        [view addGestureRecognizer:pan];
        _pan = pan;
        
    } else {
        
        if (tempRoot) {
            [tempRoot.view removeFromSuperview];
            tempRoot = nil;
        }
        
    }
    
    [self resetNavButtons];
}

- (void)setRootController:(UIViewController *)controller animated:(BOOL)animated {
    
    if (!controller)
    {
        [self setRootViewController:controller];
        return;
    }
    
    if (_menuFlags.showingLeftView)
    {
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        // slide out then come back with the new root
        __block WXYRootMenuBaseCtrl *selfRef = self;
        __block UIViewController *rootRef = _root;
        CGRect frame = rootRef.view.frame;
        frame.origin.x = rootRef.view.bounds.size.width;
        
        [UIView animateWithDuration:.1 animations:^{
            
            rootRef.view.frame = frame;
            
        } completion:^(BOOL finished) {
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            [selfRef setRootViewController:controller];
            _root.view.frame = frame;
            [selfRef showRootController:animated];
            
        }];
        
    }
    else
    {
        
        // just add the root and move to it if it's not center
        [self setRootViewController:controller];
        [self showRootController:animated];
        
    }
    
}


#pragma mark - Root Controller Navigation

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    NSAssert((_root!=nil), @"no root controller set");
    
    UINavigationController *navController = nil;
    
    if ([_root isKindOfClass:[UINavigationController class]]) {
        
        navController = (UINavigationController*)_root;
        
    } else if ([_root isKindOfClass:[UITabBarController class]]) {
        
        UIViewController *topController = [(UITabBarController*)_root selectedViewController];
        if ([topController isKindOfClass:[UINavigationController class]]) {
            navController = (UINavigationController*)topController;
        }
        
    }
    
    if (navController == nil) {
        
        NSLog(@"root controller is not a navigation controller.");
        return;
    }
    
    
    if (_menuFlags.showingRightView)//手势滑动切换viewCtrl的变量控制
    {
        
        // if we're showing the right it works a bit different, we'll make a screen shot of the menu overlay, then push, and move everything over
        __block CALayer *layer = [CALayer layer];
        CGRect layerFrame = self.view.bounds;
        layer.frame = layerFrame;
        
        UIGraphicsBeginImageContextWithOptions(layerFrame.size, YES, 0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [self.view.layer renderInContext:ctx];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        layer.contents = (id)image.CGImage;
        
        [self.view.layer addSublayer:layer];
        [navController pushViewController:viewController animated:NO];
        CGRect frame = _root.view.frame;
        frame.origin.x = frame.size.width;
        _root.view.frame = frame;
        frame.origin.x = 0.0f;
        
        CGAffineTransform currentTransform = self.view.transform;
        
        [UIView animateWithDuration:0.25f animations:^{
            
            if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                
                self.view.transform = CGAffineTransformConcat(currentTransform, CGAffineTransformMakeTranslation(0, -[[UIScreen mainScreen] applicationFrame].size.height));
                
            } else {
                
                self.view.transform = CGAffineTransformConcat(currentTransform, CGAffineTransformMakeTranslation(-[[UIScreen mainScreen] applicationFrame].size.width, 0));
            }
            
            
        } completion:^(BOOL finished) {
            
            [self showRootController:NO];
            self.view.transform = CGAffineTransformConcat(currentTransform, CGAffineTransformMakeTranslation(0.0f, 0.0f));
            [layer removeFromSuperlayer];
            
        }];
        
    }
    else //官方正常的viewCtrl切换
    {
        
        [navController pushViewController:viewController animated:animated];
        
    }
    
}


#pragma mark - Actions

- (void)showLeft:(id)sender {
    
    [self showLeftController:YES];
    
}

- (void)showRight:(id)sender {
    
    [self showRightController:YES];
    
}

@end
