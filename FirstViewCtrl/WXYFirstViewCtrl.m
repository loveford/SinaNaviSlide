//
//  WXYFirstViewCtrl.m
//  RootMenuCtrl
//
//  Created by weixianyu on 3/27/13.
//  Copyright (c) 2013 weixianyu. All rights reserved.
//

#import "WXYFirstViewCtrl.h"
#import "WXYSecondViewCtrl.h"
#import "WXYAppDelegate.h"

@interface WXYFirstViewCtrl ()

@end

@implementation WXYFirstViewCtrl

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
    // Do any additional setup after loading the view from its nib.
    [self.mainButton addSubview:self.subView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.view.frame = CGRectMake(0, self.navigationController.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
            self.navigationController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonclicked:(id)sender {
    UINavigationController *menuController = (UINavigationController*)((WXYAppDelegate*)[[UIApplication sharedApplication] delegate]).topNavCtrl;
    
    WXYSecondViewCtrl *controller = [[WXYSecondViewCtrl alloc] init];
    
    [((WXYAppDelegate*)[[UIApplication sharedApplication] delegate]) screenShots];
    [menuController pushViewController:controller animated:YES];
    
}

- (void)dealloc {
    [_mainButton release];
    [_subView release];
    [_subButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMainButton:nil];
    [self setSubView:nil];
    [self setSubButton:nil];
    [super viewDidUnload];
}
@end
