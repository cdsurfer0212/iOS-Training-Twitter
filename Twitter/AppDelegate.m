//
//  AppDelegate.m
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MenuViewController.h"
#import "NavigationController.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#import "TweetsViewController.h"
#import "ProfileViewController.h"
#import <MMDrawerController.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"AppDelegate-didFinishLaunchingWithOptions");
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:UserDidLogoutNotification object:nil];
    
    User *user = [User currentUser];
    [User addValidAccount:user]; // need to move to another place
    NavigationController *navigationController;
    if (user != nil) {
        //NSLog(@"Welcome %@", user.name);
        //TweetsViewController *tweetsViewController = [[TweetsViewController alloc] init];
        ProfileViewController *tweetsViewController = [[ProfileViewController alloc] init];
        tweetsViewController.user = [User currentUser];
        
        navigationController = [[NavigationController alloc] initWithRootViewController:tweetsViewController];

        navigationController.navigationItem.title = @"Test";
        
        self.window.rootViewController = navigationController;
        
        MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:[[MenuViewController alloc] init] rightDrawerViewController:nil];
        drawerController = [[MMDrawerController alloc] initWithCenterViewController:navigationController leftDrawerViewController:[[MenuViewController alloc] init] rightDrawerViewController:nil];
        [drawerController setShowsShadow:YES];
        [drawerController setRestorationIdentifier:@"MMDrawer"];
        [drawerController setMaximumLeftDrawerWidth:320.0];
        [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        
        [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
            /*
             MMDrawerControllerDrawerVisualStateBlock block;
             block = [[MMExampleDrawerVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
             if (block) {
                 block(drawerController, drawerSide, percentVisible);
             }
             */
        }];
        _drawerController = drawerController;
        self.window.rootViewController = _drawerController;
    }
    else {
        NSLog(@"Not logged in");
        self.window.rootViewController = [[LoginViewController alloc] init];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)userDidLogout {
    self.window.rootViewController = [[LoginViewController alloc] init];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[TwitterClient sharedInstance] openURL:url];
    return YES;
}

@end
