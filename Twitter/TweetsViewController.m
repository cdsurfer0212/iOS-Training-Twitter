//
//  TweetsViewController.m
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "TweetsViewController.h"
#import "ComposeViewController.h"
#import "DetailViewController.h"
#import "ProfileViewController.h"
#import "User.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "TwitterClient.h"
#import <SVPullToRefresh.h>

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, DetailViewControllerDelegate, TweetCellDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSNumber *lastId;
@property (strong, nonatomic) NSMutableArray *tweets;

@end

@implementation TweetsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //NSLog(@"TweetsViewController-init");
    }
    return self;
}

-(void)viewWillLayoutSubviews {
    //NSLog(@"TweetsController-viewWillLayoutSubviews");
    
    //CGRect newFrame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    //self.tableView.frame = newFrame;
    
    //CGRect newFrame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    //self.view.frame = newFrame;
    
    //self.myNavigationBar.frame = self.navigationController.navigationBar.frame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NSLog(@"TweetsController-viewDidLoad");
    
    // not work; move to viewWillLayoutSubviews
    //CGRect newFrame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.tableView.frame.size.width, self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    //self.tableView.frame = newFrame;
    
    //CGRect newFrame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    //self.view.frame = newFrame;
    
    //NSLog(@"%ld", (long)self.navigationController.navigationBar.frame.size.height);
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // 不知道怎麼設數字
    //self.tableView.estimatedRowHeight = 1.1;
    self.tableView.estimatedRowHeight = 335; // average of 110 and 295 (+40)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCellWithMedia"];
    
    [self getTweets];
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [self getTweets];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self getNewTweets];
    }];
    
    [self setNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogout:(id)sender {
    [User logout];
}

- (IBAction)onNew:(id)sender {
    //NSLog(@"onNew");
    
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.delegate = self;
    composeViewController.user = [User currentUser];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ComposeViewController delegate methods

- (void)composeViewController:(ComposeViewController *)composeViewController didSuccessfullyComposeTweet:(Tweet *)tweet {
    [self.tweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    Tweet *displayTweet = self.tweets[indexPath.row];
    if (displayTweet.retweetedTweet) {
        displayTweet = displayTweet.retweetedTweet;
    }
    
    if ([displayTweet.mediaArray count] != 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCellWithMedia"];
    }
    
    cell.delegate = self;
    cell.tweet = self.tweets[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    detailViewController.delegate = self;
    detailViewController.tweet = self.tweets[indexPath.row];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"set height");
    Tweet *tweet = self.tweets[indexPath.row];
    Tweet *displayTweet = tweet;
    
    if (tweet.retweetedTweet) {
        displayTweet = tweet.retweetedTweet;
    }
    
    if ([displayTweet.mediaArray count] == 0) {
        return 110;
    }
    else {
        return 295;
    }
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

#pragma mark - DetailViewController delegate methods

- (void)didReply:(DetailViewController *)detailViewController {
}

- (void)didChangeFavorite:(DetailViewController *)detailViewController {
    [self invokeFavoriteAPI:detailViewController.tweet];
    [self.tableView reloadData];
}

- (void)didChangeRetweet:(DetailViewController *)detailViewController {
    [self invokeRetweetAPI:detailViewController.tweet];
    [self.tableView reloadData];
}

#pragma mark - TweetCell delegate methods

- (void)didReplyFromTweetCell:(TweetCell *)tweetCell {
    ComposeViewController *composeViewController = [[ComposeViewController alloc] init];
    composeViewController.user = [User currentUser];
    composeViewController.inReplyToTweet = tweetCell.tweet;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)didChangeFavoriteFromTweetCell:(TweetCell *)tweetCell {
    [self invokeFavoriteAPI:tweetCell.tweet];
    [self.tableView reloadData];
}

- (void)didChangeRetweetFromTweetCell:(TweetCell *)tweetCell {
    [self invokeRetweetAPI:tweetCell.tweet];
    [self.tableView reloadData];
}

- (void)didTapProfileImageFromTweetCell:(TweetCell *)tweetCell {
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    
    if (tweetCell.tweet.retweetedTweet) {
        profileViewController.user = tweetCell.tweet.retweetedTweet.user;
    }
    else {
        profileViewController.user = tweetCell.tweet.user;
    }
    
    [self.navigationController pushViewController:profileViewController animated:YES];
}


#pragma mark - Private methods

- (void)invokeFavoriteAPI:(Tweet *)tweet {
    if (tweet.favorited) {
        NSDictionary *params = @{@"id" : tweet.id};
        [[TwitterClient sharedInstance] favoriteWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
    }
    else {
        NSDictionary *params = @{@"id" : tweet.id};
        [[TwitterClient sharedInstance] cancelFavoriteWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
    }
}

- (void)invokeRetweetAPI:(Tweet *)tweet {
    if (tweet.retweeted) {
        NSDictionary *params = @{@"id" : tweet.id};
        [[TwitterClient sharedInstance] retweetWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
    }
    else {
        NSDictionary *params = @{@"id" : tweet.id};
        [[TwitterClient sharedInstance] cancelRetweetWithParams:params completion:^(id responseObject, NSError *error) {
            if (error) {
                return;
            }
        }];
    }
}

- (void)getTweets {
    if (self.timelineType == TimelineTypeUser) {
        [[TwitterClient sharedInstance] userTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
            
            self.tweets = [NSMutableArray arrayWithArray:tweets];
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
            
            self.lastId = [(Tweet *)[tweets lastObject] id];
        }];
    }
    else if (self.timelineType == TimelineTypeMentions) {
        [[TwitterClient sharedInstance] mentionsTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
            
            self.tweets = [NSMutableArray arrayWithArray:tweets];
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
            
            self.lastId = [(Tweet *)[tweets lastObject] id];
        }];
    }
    else {
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
        
        self.tweets = [NSMutableArray arrayWithArray:tweets];
        [self.tableView reloadData];
        [self.tableView.pullToRefreshView stopAnimating];
        
        self.lastId = [(Tweet *)[tweets lastObject] id];
    }];
    }
}

- (void)getNewTweets {
    NSNumber *count = [NSNumber numberWithInt:11];
    NSDictionary *params = @{@"count": count, @"max_id": self.lastId};
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            [self.tableView.infiniteScrollingView stopAnimating];
            return;
        }
        
        int startingRow = [self.tweets count];
        
        NSMutableArray *newTweets = [NSMutableArray arrayWithArray:tweets];
        [newTweets removeObjectAtIndex:0]; // remove redundant tweet (max_id is inclusive)
        [self.tweets addObjectsFromArray:newTweets];
        
        [self.tableView reloadData];
        /*
        int endingRow = [self.tweets count];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (; startingRow < endingRow; startingRow++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        */
        
        [self.tableView.infiniteScrollingView stopAnimating];
        
        self.lastId = [(Tweet *)[self.tweets lastObject] id];
        
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(self.tweets.count - newTweets.count - 1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        });
        */
    }];
}

- (void)setNavigationBar {
    self.navigationController.navigationBar.barTintColor = self.myNavigationBar.barTintColor;
    self.navigationController.navigationBar.titleTextAttributes = self.myNavigationBar.titleTextAttributes;
    self.navigationItem.title = self.myNavigationBar.topItem.title;
    self.navigationItem.leftBarButtonItem = self.myNavigationBar.topItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.myNavigationBar.topItem.rightBarButtonItem;

    //self.title = @"Twitter";
    
    //self.navigationController.navigationBarHidden = YES;
    
    switch (self.timelineType) {
        case TimelineTypeHome:
            self.title = @"Home";
            break;
        case TimelineTypeUser:
            self.title = @"User";
            break;
        case TimelineTypeMentions:
            self.title = @"Mentions";
        default:
            break;
    }
}

@end
