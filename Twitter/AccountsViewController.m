//
//  AccountsViewController.m
//  Twitter
//
//  Created by Sean Zeng on 7/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "AccountsViewController.h"
#import "AccountCell.h"
#import "AccountAddCell.h"
#import "AppDelegate.h"
#import "NavigationController.h"
#import "TweetsViewController.h"
#import "TwitterClient.h"
#import "User.h"

@interface AccountsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AccountsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.accounts = [User validAccounts];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 40;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountCell" bundle:nil] forCellReuseIdentifier:@"AccountCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AccountAddCell" bundle:nil] forCellReuseIdentifier:@"AccountAddCell"];
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

#pragma mark Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accounts.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        AccountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
        cell.user = [User currentUser];
        return cell;
    } else if (indexPath.row == self.accounts.count) {
        AccountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AccountAddCell"];
        return cell;
    } else {
        AccountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
        cell.user = self.accounts[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.accounts.count) {
        [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
            if (user != nil) {
                // Modally present tweets view
                NSLog(@"Welcome to %@", user.name);
                
                TweetsViewController *tweetsViewController = [[TweetsViewController alloc] init];
                NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:tweetsViewController];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            }
            else {
                // Present error view
            }
        } forceLogin:YES];
    }
}

@end
