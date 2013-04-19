//
//  WXYAppDelegate.m
//  RootMenuCtrl
//
//  Created by weixianyu on 3/27/13.
//  Copyright (c) 2013 weixianyu. All rights reserved.
//

#import "WXYAppDelegate.h"
#import "WXYRootMenuBaseCtrl.h"
#import "WXYFirstViewCtrl.h"
#import "WXYSecondViewCtrl.h"
#import "QuartzCore/QuartzCore.h"

@implementation WXYAppDelegate


- (void)dealloc
{
    [_window release];
    [_menuController release];
    [_topNavCtrl release];
    [_topImageView release];
    [_imageArray release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.topImageView = [[[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]autorelease];
    self.backgroudView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]autorelease];
    self.backgroudView.backgroundColor = [UIColor blackColor];
    [self.window addSubview:self.topImageView];
    [self.window addSubview:self.backgroudView];
    //self.topImageView.image = [UIImage imageNamed:@"backImage.png"];
    // Override point for customization after application launch.
    
     WXYFirstViewCtrl *mainController = [[WXYFirstViewCtrl alloc] init];
     UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
//    
//    WXYRootMenuBaseCtrl *rootController = [[WXYRootMenuBaseCtrl alloc] initWithRootViewController:navController];
//    _menuController = rootController;
//    
//    WXYSecondViewCtrl *rightController = [[WXYSecondViewCtrl alloc] init];
//    rootController.rightViewController = rightController;
    self.topNavCtrl = navController;
    self.window.rootViewController = self.topNavCtrl;

    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)screenShots
{
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }
    else
    {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow * window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            CGContextConcatCTM(context, [window transform]);
            CGContextTranslateCTM(context, -[window bounds].size.width*[[window layer] anchorPoint].x, -[window bounds].size.height*[[window layer] anchorPoint].y);
            [[window layer] renderInContext:context];
            
            CGContextRestoreGState(context);
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    if (!self.imageArray)
    {
        self.imageArray = [NSMutableArray array];
    }
    [self.imageArray  addObject:image];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    NSLog(@"Suceeded!");
}

- (void)configGesstureInfo:(UIView*)view
{
    if (self.imageArray && self.imageArray.count>0)
    {
        UIImage*image = [self.imageArray lastObject];
        self.topImageView.image = image;
    }
    self.currentView = view;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
    [self.currentView addGestureRecognizer:panGesture];
    [panGesture release];
}


#pragma mark -UIPanGestureRecognizer Selector
-(void)handelPan:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.lastInstance = 0.0;
        return;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat xOffSet = [gestureRecognizer translationInView:self.currentView].x;
        CGFloat translateX = xOffSet -  self.lastInstance;
        self.lastInstance = xOffSet;
        [self slideView:translateX];
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self slideAnimationView];
        self.lastInstance = 0.0;
        
    }
}


- (void)slideView:(CGFloat)translate
{
    CGFloat x = self.topNavCtrl.view.frame.origin.x + translate;
    if (x<0) {
        x=0;
    }
    else if(x>270){
        x=270;
    }
    self.topNavCtrl.view.frame = CGRectMake(x,self.topNavCtrl.view.frame.origin.y, self.topNavCtrl.view.frame.size.width, self.topNavCtrl.view.frame.size.height);
    float alpha = 1-x/250;
     self.backgroudView.alpha = alpha;
    self.topImageView.frame = CGRectMake(1000/x,1000/x, self.topImageView.frame.size.width, self.topImageView.frame.size.height);

}

- (void)slideAnimationView
{
    CGFloat x = self.topNavCtrl.view.frame.origin.x;
    if (x>=180) {
        CGFloat time = (270-x)/1000;
        [UIView animateWithDuration:time animations:^{
            self.topNavCtrl.view.frame = CGRectMake(270, self.topNavCtrl.view.frame.origin.y, self.topNavCtrl.view.frame.size.width, self.topNavCtrl.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            [self back];
        }];
    }
    else{
        CGFloat time = x/2000;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:time];
        [UIView setAnimationDelegate:self];
        self.topNavCtrl.view.frame = CGRectMake(0, self.topNavCtrl.view.frame.origin.y, self.topNavCtrl.view.frame.size.width, self.topNavCtrl.view.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)back
{
    //self.navigationController.view.alpha = 0.0;
    [self.topNavCtrl popViewControllerAnimated:NO];
    self.topNavCtrl.view.frame = CGRectMake(0, self.topNavCtrl.view.frame.origin.y, self.topNavCtrl.view.frame.size.width, self.topNavCtrl.view.frame.size.height);
    //self.navigationController.view.alpha = 1.0;
    [self  configBackInfo];
}

- (void)configBackInfo
{
    if (self.imageArray && self.imageArray.count>0)
    {
        [self.imageArray removeLastObject];
        if (self.imageArray && self.imageArray.count>0)
        {
            self.topImageView.image = [self.imageArray lastObject];
        }
    }
}

@end
