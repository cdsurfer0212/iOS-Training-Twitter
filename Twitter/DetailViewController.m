//
//  DetailViewController.m
//  Twitter
//
//  Created by Sean Zeng on 6/29/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "DetailViewController.h"
#import "ComposeViewController.h"
#import "TwitterClient.h"
#import <UIImageView+AFNetworking.h>

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;

@property (weak, nonatomic) IBOutlet UIImageView *retweetedTweetImageView;
@property (weak, nonatomic) IBOutlet UILabel *retweetedTweetLabel;


@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    Tweet *displayTweet = _tweet;
    if (self.tweet.retweetedTweet) {
        self.retweetedTweetLabel.text = [self.tweet.user.name stringByAppendingString:@" retweeted"];
        displayTweet = _tweet.retweetedTweet;
    }
    
    self.nameLabel.text = displayTweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", displayTweet.user.screenName];
    self.textLabel.text = displayTweet.text;
    
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%@", displayTweet.favoriteCount];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", displayTweet.retweetCount];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"M/d/y, h:mm a";
    self.createdAtLabel.text = [dateFormatter stringFromDate:displayTweet.createdAt];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:displayTweet.user.profileImageUrl]];
    [self.profileImageView setImageWithURLRequest:request placeholderImage:nil
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:self.profileImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    self.profileImageView.image = image;
                }
                completion: nil
            ];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }
    ];
    
    self.title = @"Tweet";
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //self.profileImageView.layer.cornerRadius = 4;
    
    if ([self.tweet.user.id isEqualToNumber:[User currentUser].id] || self.tweet.user.protected) {
        self.retweetButton.enabled = NO;
    }
    
    if (self.tweet.retweeted) {
        UIImage *btnImage = [UIImage imageNamed:@"ic_retweet_true"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    if (self.tweet.favorited) {
        UIImage *btnImage = [UIImage imageNamed:@"ic_star_true"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    if (!self.tweet.retweetedTweet) {
        self.profileImageView.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect newProfileImageViewFrame = CGRectMake(self.profileImageView.frame.origin.x, self.retweetedTweetImageView.frame.origin.y, self.profileImageView.frame.size.width, self.profileImageView.frame.size.height);
        self.profileImageView.frame = newProfileImageViewFrame;
        
        self.retweetedTweetImageView.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect newRetweetedTweetImageViewFrame = CGRectMake(self.retweetedTweetImageView.frame.origin.x, self.retweetedTweetImageView.frame.origin.y, self.retweetedTweetImageView.frame.size.width, 0);
        self.retweetedTweetImageView.frame = newRetweetedTweetImageViewFrame;
        
        self.retweetedTweetLabel.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect newRetweetedTweetLabelFrame = CGRectMake(self.retweetedTweetLabel.frame.origin.x, self.retweetedTweetLabel.frame.origin.y, self.retweetedTweetLabel.frame.size.width, 0);
        self.retweetedTweetLabel.frame = newRetweetedTweetLabelFrame;
    }
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

#pragma mark - Private methods

- (IBAction)onReply:(id)sender {
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.user = [User currentUser];
    composeViewController.inReplyToTweet = self.tweet;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)onRetweet:(id)sender {
    if (self.tweet.retweeted) {
        /*
        NSDictionary *params = @{@"id" : self.tweet.id};
        [[TwitterClient sharedInstance] cancelRetweetWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
        */
        
        [self.tweet updateRetweet:NO];
        UIImage *btnImage = [UIImage imageNamed:@"ic_retweet_false"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        /*
        NSDictionary *params = @{@"id" : self.tweet.id};
        [[TwitterClient sharedInstance] retweetWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
        */
        
        [self.tweet updateRetweet:YES];
        UIImage *btnImage = [UIImage imageNamed:@"ic_retweet_true"];
        [self.retweetButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweetCount];
    
    [self.delegate didChangeRetweet:self];
}

- (IBAction)onStar:(id)sender {
    if (self.tweet.favorited) {
        /*
        NSDictionary *params = @{@"id" : self.tweet.id};
        [[TwitterClient sharedInstance] cancelFavoriteWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
        */
        
        [self.tweet updateFavorite:NO];
        UIImage *btnImage = [UIImage imageNamed:@"ic_star_false"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    else {
        /*
        NSDictionary *params = @{@"id" : self.tweet.id};
        [[TwitterClient sharedInstance] favoriteWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
        */
        
        [self.tweet updateFavorite:YES];
        UIImage *btnImage = [UIImage imageNamed:@"ic_star_true"];
        [self.favoriteButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.favoriteCount];
    
    [self.delegate didChangeFavorite:self];
}

@end
