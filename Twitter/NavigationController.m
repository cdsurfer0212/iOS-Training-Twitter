//
//  NavigationController.m
//  Twitter
//
//  Created by Sean Zeng on 6/28/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"NavigationController-viewDidLoad");
    
    self.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationBar.barTintColor = _myNavigationBar.barTintColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
