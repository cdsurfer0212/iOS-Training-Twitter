//
//  TweetCell.m
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "TweetCell.h"
#import "TwitterClient.h"
#import <NSDate+DateTools.h>
#import <UIImageView+AFNetworking.h>

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    //[self.contentView setNeedsLayout];
    //[self.contentView layoutIfNeeded];
    
    self.storyTextLabel.preferredMaxLayoutWidth = self.storyTextLabel.frame.size.width;
    /*
    if (self.storyTextLabel.numberOfLines == 0 && self.storyTextLabel.preferredMaxLayoutWidth != CGRectGetWidth(self.storyTextLabel.frame)) {
        self.storyTextLabel.preferredMaxLayoutWidth = self.storyTextLabel.frame.size.width;
        [self.storyTextLabel setNeedsUpdateConstraints];
    }
    
    [self.storyTextLabel setNeedsLayout];
    [self.storyTextLabel layoutIfNeeded];
    */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom setters

- (void)setTweet:(Tweet *)tweet {
    //NSLog(@"set tweet");
    _tweet = tweet;
    
    Tweet *displayTweet = _tweet;
    if (self.tweet.retweetedTweet) {
        displayTweet = _tweet.retweetedTweet;
    }
    
    self.nameLabel.text = displayTweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", displayTweet.user.screenName];
    self.storyTextLabel.text = displayTweet.text;
    self.createdAtLabel.text = displayTweet.createdAt.shortTimeAgoSinceNow;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:displayTweet.user.profileImageUrl]];
    [self.profileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [UIView transitionWithView:self.profileImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
            animations:^{
                self.profileImageView.image = image;
            }
            completion: nil
        ];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
    
    if ([displayTweet.user.id isEqualToNumber:[User currentUser].id] || displayTweet.user.protected) {
        self.retweetButton.enabled = NO;
    }
    else {
        self.retweetButton.enabled = YES;
    }
    
    if (displayTweet.retweeted) {
        UIImage *btnImage = [UIImage imageNamed:@"ic_retweet_true"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        UIImage *btnImage = [UIImage imageNamed:@"ic_retweet_false"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    
    if (displayTweet.favorited) {
        UIImage *btnImage = [UIImage imageNamed:@"ic_star_true"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        UIImage *btnImage = [UIImage imageNamed:@"ic_star_false"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    if (!displayTweet.retweetedTweet) {
        /*
        self.profileImageView.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect newProfileImageViewFrame = CGRectMake(self.profileImageView.frame.origin.x, self.retweetedTweetImageView.frame.origin.y, self.profileImageView.frame.size.width, self.profileImageView.frame.size.height);
        self.profileImageView.frame = newProfileImageViewFrame;
        
        self.retweetedTweetImageView.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect newRetweetedTweetImageViewFrame = CGRectMake(self.retweetedTweetImageView.frame.origin.x, self.retweetedTweetImageView.frame.origin.y, self.retweetedTweetImageView.frame.size.width, 0);
        self.retweetedTweetImageView.frame = newRetweetedTweetImageViewFrame;
        */
    }

    //NSLog(@"%ld", [displayTweet.mediaArray count]);
    self.mediaImageView.image = nil;
    if ([displayTweet.mediaArray count] == 0) {
        //self.replyButton.translatesAutoresizingMaskIntoConstraints = YES;
        //self.replyButton.autoresizingMask = UIViewAutoresizingNone;
        //[self addConstraint:self.replyButtonBottomMargin];
        
        /*
        CGRect newReplyButtonFrame = CGRectMake(self.replyButton.frame.origin.x, self.mediaImageView.frame.origin.y, self.replyButton.frame.size.width, self.replyButton.frame.size.height);
        self.replyButton.frame = newReplyButtonFrame;
        */
        
        //self.mediaImageView.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect newMediaImageViewFrame = CGRectMake(self.mediaImageView.frame.origin.x, self.mediaImageView.frame.origin.y, self.mediaImageView.frame.size.width, 0);
        self.mediaImageView.frame = newMediaImageViewFrame;
        //[self.mediaImageView removeConstraint:self.mediaImageHeightConstraint];
        self.mediaImageHeightConstraint.constant = 0;
        self.mediaImageTopMarginConstraint.constant = 0;
    }
    else {
        for (int i = 0; i < [displayTweet.mediaArray count]; i++) {
            Media *media = [displayTweet.mediaArray objectAtIndex:i];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:media.mediaUrl]];
            
            //UIImageView *imageView = [[UIImageView alloc] init];
            //__weak UIImageView *weakImageView = imageView;
            [self.mediaImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                //NSLog(@"load tweet image");
                //UIImageView *strongImageView = weakImageView;
                [UIView transitionWithView:self.mediaImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.mediaImageView.image = image;
                    }
                    completion: nil
                 ];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"%@", error);
            }];

            self.storyTextLabel.text = [self.storyTextLabel.text stringByReplacingOccurrencesOfString:media.url withString:@""];
        }
        
        //[self.mediaImageView addConstraint:self.mediaImageHeightConstraint];
        self.mediaImageHeightConstraint.constant = 175;
        self.mediaImageTopMarginConstraint.constant = 10;
    }
    
    //NSLog(@"%f", self.storyTextLabel.frame.size.height);
    //[self.storyTextLabel sizeToFit];
    //NSLog(@"%f", self.storyTextLabel.frame.size.height);
    
    //NSLog(@"media image: %f", self.mediaImageView.frame.size.height);
    //NSLog(@"cell image: %f, %f", self.frame.size.height, self.contentView.frame.size.height);
    
    //[self.storyTextLabel setNeedsLayout];
    //[self.storyTextLabel layoutIfNeeded];
    //[self.mediaImageView setNeedsLayout];
    //[self.mediaImageView layoutIfNeeded];
    //[self setNeedsLayout];
    //[self layoutIfNeeded];
    
    //NSLog(@"media image: %f", self.mediaImageView.frame.size.height);
    //NSLog(@"cell image: %f, %f", self.frame.size.height, self.contentView.frame.size.height);
}

#pragma mark - Private methods

- (IBAction)onReply:(id)sender {
    [self.delegate didReplyFromTweetCell:self];
}

- (IBAction)onRetweet:(id)sender {
    if (self.tweet.retweeted) {
        [self.tweet updateRetweet:NO];
        UIImage *btnImage = [UIImage imageNamed:@"ic_retweet_false"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        [self.tweet updateRetweet:YES];
        UIImage *btnImage = [UIImage imageNamed:@"ic_retweet_true"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    //self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweetCount];
    
    [self.delegate didChangeRetweetFromTweetCell:self];
}

- (IBAction)onStar:(id)sender {
    if (self.tweet.favorited) {
        [self.tweet updateFavorite:NO];
        UIImage *btnImage = [UIImage imageNamed:@"ic_star_false"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        [self.tweet updateFavorite:YES];
        UIImage *btnImage = [UIImage imageNamed:@"ic_star_true"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    //self.favoriteCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.favoriteCount];
    
    [self.delegate didChangeFavoriteFromTweetCell:self];
}

@end
