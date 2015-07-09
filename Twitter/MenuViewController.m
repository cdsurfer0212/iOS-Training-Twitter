//
//  MenuViewController.m
//  Twitter
//
//  Created by Sean Zeng on 7/2/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuOptionCell.h"
#import "AccountsViewController.h"
#import "NavigationController.h"
#import "ProfileViewController.h"
#import "TweetsViewController.h"
#import "UIViewController+MMDrawerController.h"
#import <UIImageView+AFNetworking.h>

typedef NS_ENUM(NSInteger, MenuOption) {
    MenuOptionProfile = 0,
    MenuOptionTimeline = 1,
    MenuOptionMentions = 2,
    MenuOptionAccounts = 3
};

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"MenuOptionCell" bundle:nil] forCellReuseIdentifier:@"MenuOptionCell"];
    
    self.tableView.estimatedRowHeight = 24;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.nameLabel.text = [User currentUser].name;
    self.screenNameLabel.text = [User currentUser].screenName;
    
    NSURLRequest *profileImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[User currentUser].profileImageUrl]];
    [self.imageView setImageWithURLRequest:profileImageRequest placeholderImage:[UIImage imageNamed:@""]
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [UIView transitionWithView:self.imageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve
                animations:^{
                    self.imageView.image = image;
                }
                completion: nil
            ];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"%@", error);
        }
    ];
    
    self.imageView.layer.cornerRadius = 30;
    self.imageView.layer.masksToBounds = YES;
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

#pragma mark - Table view delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuOptionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MenuOptionCell"];
    if (indexPath.row == MenuOptionProfile) {
        cell.titleLabel.text = @"Profile";
        cell.profileImageView.image = [UIImage imageNamed: @"ic_profile"];
        return cell;
    }
    else if (indexPath.row == MenuOptionTimeline) {
        cell.titleLabel.text = @"Timeline";
        cell.profileImageView.image = [UIImage imageNamed: @"ic_timeline"];
        return cell;
    }
    else if (indexPath.row == MenuOptionMentions) {
        cell.titleLabel.text = @"Mentions";
        cell.profileImageView.image = [UIImage imageNamed: @"ic_mention"];
        return cell;
    }
    else {
        cell.titleLabel.text = @"Accounts";
        cell.profileImageView.image = [UIImage imageNamed: @"ic_account"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case MenuOptionProfile:{
            ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
            profileViewController.user = [User currentUser];
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:profileViewController];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            break;
        }
        case MenuOptionTimeline: {
            TweetsViewController *tweetsViewController = [[TweetsViewController alloc] init];
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:tweetsViewController];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            break;
        }
        case MenuOptionMentions: {
            TweetsViewController *mentionsViewController = [[TweetsViewController alloc] init];
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:mentionsViewController];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            mentionsViewController.timelineType = TimelineTypeMentions;
            break;
        }
        case MenuOptionAccounts: {
            AccountsViewController *accountsViewController = [[AccountsViewController alloc] init];
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:accountsViewController];
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

@end
