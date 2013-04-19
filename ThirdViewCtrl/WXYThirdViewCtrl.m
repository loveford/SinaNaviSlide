//
//  WXYThirdViewCtrl.m
//  RootMenuCtrl
//
//  Created by weixianyu on 3/27/13.
//  Copyright (c) 2013 weixianyu. All rights reserved.
//

#import "WXYThirdViewCtrl.h"
#import "WXYFourthViewCtrl.h"
#import "WXYAppDelegate.h"
#import "WXYRootMenuBaseCtrl.h"


@interface WXYThirdViewCtrl ()
  @property (assign, nonatomic) float lastInstance;
@end

@implementation WXYThirdViewCtrl

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
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
//    [self.view addGestureRecognizer:panGesture];
//    [panGesture release];
    // Do any additional setup after loading the view from its nib.
    WXYAppDelegate*delegate =(WXYAppDelegate*) ([[UIApplication sharedApplication] delegate]);
    [delegate configGesstureInfo:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        CGFloat xOffSet = [gestureRecognizer translationInView:self.view].x;
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
    CGFloat x = self.navigationController.view.frame.origin.x + translate;
    if (x<0) {
        x=0;
    }
    else if(x>270){
        x=270;
    }
    self.navigationController.view.frame = CGRectMake(x,self.navigationController.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
}

- (void)slideAnimationView
{
    CGFloat x = self.navigationController.view.frame.origin.x;
    if (x>=180) {
        CGFloat time = (270-x)/1000;
        [UIView animateWithDuration:time animations:^{
            self.navigationController.view.frame = CGRectMake(270, self.navigationController.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
            
        } completion:^(BOOL finished) {
            [self back];
        }];
        
        //        [UIView beginAnimations:nil context:nil];
        //        [UIView setAnimationDidStopSelector:@selector(back)];
        //        [UIView setAnimationDuration:time];
        //
        //        [UIView commitAnimations];
    }
    else{
        CGFloat time = x/2000;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:time];
        [UIView setAnimationDelegate:self];
        self.navigationController.view.frame = CGRectMake(0, self.navigationController.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)back
{
    NSLog(@"SSS third nav ctrl view frame = %@",NSStringFromCGRect( self.navigationController.view.frame));
    //
    self.navigationController.view.frame = CGRectMake(0, 0, 320, 568);
    [self.navigationController popViewControllerAnimated:NO];
    self.navigationController.view.alpha = 0.0;
    //self.navigationController.view.alpha = 1.0;
    NSLog(@"EEE third nav ctrl view frame = %@",NSStringFromCGRect( self.navigationController.view.frame));
}


- (IBAction)buttonclicked:(id)sender
{
    UINavigationController *menuController = (UINavigationController*)((WXYAppDelegate*)[[UIApplication sharedApplication] delegate]).topNavCtrl;
    
    WXYFourthViewCtrl *controller = [[WXYFourthViewCtrl alloc] init];
    
    [((WXYAppDelegate*)[[UIApplication sharedApplication] delegate]) screenShots];
    [menuController pushViewController:controller animated:YES];
}
@end
