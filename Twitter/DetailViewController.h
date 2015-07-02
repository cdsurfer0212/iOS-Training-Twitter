//
//  DetailViewController.h
//  Twitter
//
//  Created by Sean Zeng on 6/29/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class DetailViewController;

@protocol DetailViewControllerDelegate <NSObject>

- (void)didChangeFavorite:(DetailViewController *)detailViewController;
- (void)didChangeRetweet:(DetailViewController *)detailViewController;

@end

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet;

@property (strong, nonatomic) id<DetailViewControllerDelegate> delegate;

@end
