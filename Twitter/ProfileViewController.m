//
//  ProfileViewController.m
//  Twitter
//
//  Created by Sean Zeng on 7/2/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "TweetCell.h"
#import "TwitterClient.h"
#import <FXBlurView.h>
#import <UIImageView+AFNetworking.h>

CGFloat const headerStopTransformationOffset = 40.0;
CGFloat const headerLabelReachHeaderOffset = 90.0;
CGFloat const maxHeaderLabelTranslationDistance = 35.0;

@interface ProfileViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, TweetCellDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredHeaderImageView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) NSInteger descriptionViewIndex;
@property (assign, nonatomic) CGPoint descriptionView1CenterPosition;
@property (assign, nonatomic) CGPoint descriptionView2CenterPosition;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *descriptionViewPanGestureRecognizer;

@property (strong, nonatomic) NSMutableArray *tweets;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initializeLayout];
    
    //NSLog(@"%f", self.view.bounds.size.width);
    //NSLog(@"%f", self.view.frame.size.width);
    
    [self setNavigationBar];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 3.0;
    
    self.scrollView.delegate = self;
    CGSize contentSize = self.view.bounds.size;
    contentSize.height *= 2;
    self.scrollView.contentSize = contentSize;
    [self.view addGestureRecognizer:self.scrollView.panGestureRecognizer];
    
    self.blurredHeaderImageView.alpha = 0;
    
    self.descriptionViewIndex = 0;
    self.descriptionView1CenterPosition = self.descriptionView.center;
    self.descriptionView2CenterPosition = CGPointMake(self.descriptionView1CenterPosition.x - self.view.frame.size.width, self.descriptionView1CenterPosition.y);
    self.descriptionViewPanGestureRecognizer.delegate = self;
    
    //NSLog(@"descriptionView1CenterPosition: %f", self.descriptionView1CenterPosition);
    //NSLog(@"descriptionView2CenterPosition: %f", self.descriptionView2CenterPosition);
    
    //NSLog(@"frame width: %f", self.view.frame.size.width);
    
    [self getTweets];
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

#pragma mark - gesture recognizer delegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    return fabs(velocity.x) > fabs(velocity.y);
}


#pragma mark - Scroll view delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 往上拉 offset 越小
    // 往下捲 offset 越大
    CGFloat offset = scrollView.contentOffset.y;
    NSLog(@"==========");
    NSLog(@"offset y: %f", offset);
    //NSLog(@"%ld", (long)self.profileImageView.bounds.origin.y);
    //NSLog(@"%ld", (long)self.profileImageView.frame.origin.y);
    //NSLog(@"%ld", (long)self.profileImageView.bounds.size.height);
    //NSLog(@"%ld", (long)self.profileImageView.frame.size.height);

    CGSize contentSize = self.view.bounds.size;
    contentSize.height = [UIApplication sharedApplication].statusBarFrame.size.height;
    //self.scrollView.contentSize = contentSize;
    //NSLog(@"%f", contentSize.width);
    //NSLog(@"%f", contentSize.height);
    
    CGRect bounds = self.view.bounds;
    bounds.origin.y = offset;
    self.contentView.bounds = bounds;
    
    CATransform3D headerViewTransform = CATransform3DIdentity;
    CATransform3D profileImageTransform = CATransform3DIdentity;
    
    if (offset < 0) {
        CGFloat headerViewScaleFactor = -(offset) / self.headerView.bounds.size.height;
        CGFloat headerViewSizeVariation = ((self.headerView.bounds.size.height * (1.0 + headerViewScaleFactor)) - self.headerView.bounds.size.height) / 2.0;
        headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, headerViewSizeVariation, 0);
        headerViewTransform = CATransform3DScale(headerViewTransform, 1.0 + headerViewScaleFactor, 1.0 + headerViewScaleFactor, 0);

        //self.headerView.layer.transform = headerViewTransform;
        
        //NSLog(@"%f", (float)profileImageScaleFactor);
        //NSLog(@"%f", (float)profileImageSizeVariation);
    }
    else {
        headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, fmaxf(-offset, -headerStopTransformationOffset), 0);
        
        CATransform3D headerLabelTransform = CATransform3DIdentity;
        headerLabelTransform = CATransform3DTranslate(headerLabelTransform, 0, fmaxf(headerLabelReachHeaderOffset - offset, -maxHeaderLabelTranslationDistance), 0);
        self.headerLabel.layer.transform = headerLabelTransform;
        
        self.blurredHeaderImageView.alpha = fminf((offset - headerLabelReachHeaderOffset) /maxHeaderLabelTranslationDistance, 1.0);

        CGFloat profileImageScaleFactor = fminf(offset, headerStopTransformationOffset) / self.profileImageView.bounds.size.height / 1.4;
        CGFloat profileImageSizeVariation = ((self.profileImageView.bounds.size.height * (1.0 + profileImageScaleFactor)) - self.profileImageView.bounds.size.height) / 2.0;
        profileImageTransform = CATransform3DTranslate(profileImageTransform, 0, profileImageSizeVariation, 0);
        profileImageTransform = CATransform3DScale(profileImageTransform, 1.0 - profileImageScaleFactor, 1.0 - profileImageScaleFactor, 0);

        if (offset <= headerStopTransformationOffset) {
            if (self.profileImageView.layer.zPosition < self.headerView.layer.zPosition) {
                self.headerView.layer.zPosition = 0;
            }
        }
        else {
            if (self.profileImageView.layer.zPosition >= self.headerView.layer.zPosition) {
                self.headerView.layer.zPosition = 2;
            }
        }
        
        //NSLog(@"%f", (float)profileImageScaleFactor);
        //NSLog(@"profileImageSizeVariation: %f", (float)profileImageSizeVariation);
    }
    
    self.headerView.layer.transform = headerViewTransform;
    self.profileImageView.layer.transform = profileImageTransform;
    
    //NSLog(@"%ld", (long)self.profileImageView.bounds.origin.y);
    //NSLog(@"%ld", (long)self.profileImageView.frame.origin.y);
    //NSLog(@"%ld", (long)self.profileImageView.bounds.size.height);
    //NSLog(@"%ld", (long)self.profileImageView.frame.size.height);
    NSLog(@"==========");
}

#pragma mark - Table view delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    cell.delegate = self;
    cell.tweet = self.tweets[indexPath.row];
    
    return cell;
}

#pragma mark - Custom setters

- (void)setUser:(User *)user{
    _user = user;
    [self initializeLayout];
}

#pragma mark - Private methods

- (void)getTweets {
    NSDictionary *params = @{@"user_id" : self.user.id};
    [[TwitterClient sharedInstance] userTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        self.tweets = [NSMutableArray arrayWithArray:tweets];
        [self.tableView reloadData];
    }];
}

- (void)initializeLayout {
    self.nameLabel.text = self.user.name;
    self.headerLabel.text = self.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    self.descriptionLabel.text = self.user.tagline;
   
    self.followingCountLabel.text = [NSString stringWithFormat:@"%d", [self.user.followingCount intValue]];
    self.followersCountLabel.text = [NSString stringWithFormat:@"%d", [self.user.followersCount intValue]];

    NSURLRequest *profileImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    [self.profileImageView setImageWithURLRequest:profileImageRequest placeholderImage:[UIImage imageNamed:@""]
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:self.profileImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    self.profileImageView.image = image;
                }
                completion: nil
            ];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"%@", error);
        }
     ];
    
    NSURLRequest *headerImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.user.profileBannerUrl]];
    [self.headerImageView setImageWithURLRequest:headerImageRequest placeholderImage:nil
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:self.headerImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    self.headerImageView.image = image;
                }
                completion:^(BOOL finished) {
                    self.blurredHeaderImageView.image = [self.headerImageView.image blurredImageWithRadius:10.0 iterations:20.0 tintColor:nil];
                }
            ];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)onMenu {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)setNavigationBar {
    if (self.user.id == [User currentUser].id) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(onMenu)];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (IBAction)onPageControlValueChanged:(id)sender {
    [self changeDescriptionView];
}

- (void)setDescriptionView:(NSInteger)index animated:(BOOL)animated {
    if (index == 0) {
        if (animated) {
            [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut
                animations:^{
                    self.descriptionView.center = self.descriptionView1CenterPosition;
                    self.headerImageView.alpha = 1.0;
                }
                completion:nil
             ];
        }
        else {
            self.descriptionView.center = self.descriptionView1CenterPosition;
            self.headerImageView.alpha = 1.0;
        }
    }
    else if (index == 1) {
        if (animated) {
            [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveEaseInOut
                animations:^{
                    self.descriptionView.center = self.descriptionView2CenterPosition;
                    self.headerImageView.alpha = 0.5;
                }
                completion:nil
             ];
        }
        else {
            self.descriptionView.center = self.descriptionView2CenterPosition;
            self.headerImageView.alpha = 0.5;
        }
    }
    
    NSLog(@"descriptionView1CenterPosition: %f", self.descriptionView1CenterPosition);
    NSLog(@"descriptionView2CenterPosition: %f", self.descriptionView2CenterPosition);
    
    NSLog(@"frame width: %f", self.view.frame.size.width);
    
    self.descriptionViewIndex = index;
    self.pageControl.currentPage = index;
}

- (IBAction)onPanDescriptionView:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    CGPoint descriptionViewStartPosition;
    
    //NSLog(@"translation: %f", translation.x);
    //NSLog(@"velocity: %f", velocity.x);
    
    //NSLog(@"%f", panGestureRecognizer.view.center.x);
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            descriptionViewStartPosition = panGestureRecognizer.view.center;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat minCenterX = 0;
            CGFloat maxCenterX = self.view.bounds.size.width;
            CGPoint newCenterPosition = CGPointMake(fminf(maxCenterX, fmaxf(minCenterX, descriptionViewStartPosition.x + translation.x)), panGestureRecognizer.view.center.y);
            panGestureRecognizer.view.center = newCenterPosition;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGFloat minCenterX = 0;
            CGFloat maxCenterX = self.view.bounds.size.width;
            CGPoint newCenterPosition = CGPointMake(descriptionViewStartPosition.x + translation.x, panGestureRecognizer.view.center.y);
            
            if (newCenterPosition.x < minCenterX || newCenterPosition.x > maxCenterX) {
                return;
            }
            
            if (velocity.x < -200) {
                [self setDescriptionView:1 animated:YES];
            }
            else if (velocity.x > 200) {
                [self setDescriptionView:0 animated:YES];
            }
            
            if (fabsf(translation.x) > self.view.bounds.size.width / 2) {
                [self changeDescriptionView];
            }
            else {
                [self stayDescriptionView];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)changeDescriptionView {
    if (self.descriptionViewIndex == 0) {
        [self setDescriptionView:1 animated:YES];
    } else if (self.descriptionViewIndex == 1) {
        [self setDescriptionView:0 animated:YES];
    }
}

- (void)stayDescriptionView {
    [self setDescriptionView:self.descriptionViewIndex animated:YES];
}

@end
