//
//  TweetCell.h
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void)didChangeFavoriteFromTweetCell:(TweetCell *)tweetCell;
- (void)didChangeRetweetFromTweetCell:(TweetCell *)tweetCell;
- (void)didReplyFromTweetCell:(TweetCell *)tweetCell;
- (void)didTapProfileImageFromTweetCell:(TweetCell *)tweetCell;

@end

@interface TweetCell : UITableViewCell 

@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *storyTextLabel;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;

@property (weak, nonatomic) IBOutlet UIImageView *retweetedTweetImageView;
@property (weak, nonatomic) IBOutlet UILabel *retweetedTweetLabel;

@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaImageTopMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *replyButtonBottomMargin;


@property (nonatomic, strong) Tweet *tweet;

@property (strong, nonatomic) id<TweetCellDelegate> delegate;

@end
