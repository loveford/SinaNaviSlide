//
//  WXYSecondViewCtrl.m
//  RootMenuCtrl
//
//  Created by weixianyu on 3/27/13.
//  Copyright (c) 2013 weixianyu. All rights reserved.
//

#import "WXYSecondViewCtrl.h"
#import "WXYThirdViewCtrl.h"
#import "WXYAppDelegate.h"
#import "WXYRootMenuBaseCtrl.h"

@interface WXYSecondViewCtrl ()

@end

@implementation WXYSecondViewCtrl

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
    WXYAppDelegate*delegate =(WXYAppDelegate*) ([[UIApplication sharedApplication] delegate]);
    [delegate configGesstureInfo:self.view];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonclicked:(id)sender
{
    // lets just push another feed view
//    UINavigationController *menuController = (UINavigationController*)((WXYAppDelegate*)[[UIApplication sharedApplication] delegate]).topNavCtrl;
//    
//    WXYThirdViewCtrl *controller = [[WXYThirdViewCtrl alloc] init];
//    [((WXYAppDelegate*)[[UIApplication sharedApplication] delegate]) screenShots];
//    [menuController pushViewController:controller animated:YES];
    
    self.testView.alpha = self.testView.alpha-0.2;

}
- (void)dealloc {
    [_testView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTestView:nil];
    [super viewDidUnload];
}
@end
