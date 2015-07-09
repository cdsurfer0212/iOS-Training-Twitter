//
//  TweetsViewController.h
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TimelineType) {
    TimelineTypeHome = 0,
    TimelineTypeUser = 1,
    TimelineTypeMentions = 2
};

@interface TweetsViewController : UIViewController

@property (assign, nonatomic) TimelineType timelineType;

@end
