//
//  ComposeViewController.m
//  Twitter
//
//  Created by Sean Zeng on 6/29/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "ComposeViewController.h"
#import "TwitterClient.h"
#import <UIImageView+AFNetworking.h>

#define MAX_LENGTH 120

@interface ComposeViewController () <UIActionSheetDelegate, UITextViewDelegate>

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setNavigationBar];
    
    [self loadUserDataIntoView];
    
    self.textView.delegate = self;
    self.textView.text = @"";
    [self.textView becomeFirstResponder];
    
    if (self.inReplyToTweet) {
        NSString *inReplyToUserName = [NSString stringWithFormat:@"@%@ ", self.inReplyToTweet.user.screenName];
        self.textView.text = inReplyToUserName;
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

#pragma mark - Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:  // Delete
            [self.textView endEditing:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:  // Cancel
            break;
        default:
            break;
    }
}

#pragma mark - Text view delegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    
    //NSLog(@"%ld", textView.text.length);
    //NSLog(@"%ld", range.length);
    //NSLog(@"%ld", text.length);
    
    if (newLength <= MAX_LENGTH) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString* textWithoutLinebreaks = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    textView.text = textWithoutLinebreaks;
    
    int inputtedCharacters = textView.text.length;
    int remainingCharacters = MAX_LENGTH - inputtedCharacters;
    self.counterLabel.text = [NSString stringWithFormat:@"%d", remainingCharacters];
    
    if (textView.text.length > 0) {
        self.tweetButton.enabled = YES;
        self.tweetButton.alpha = 1.0f;
    }
    else {
        self.tweetButton.enabled = NO;
        self.tweetButton.alpha = 0.5f;
    }
}

#pragma mark - Private methods
- (void)loadUserDataIntoView {
    self.nameLabel.text = self.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
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
}

- (IBAction)onCancel:(id)sender {
    if (self.textView.text.length > 0) {
        UIActionSheet *popUp = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        [popUp showInView:[UIApplication sharedApplication].keyWindow];
        
    } else {
        [self.textView endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onCancel {
    if (self.textView.text.length > 0) {
        UIActionSheet *popUp = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
        [popUp showInView:[UIApplication sharedApplication].keyWindow];
        
    } else {
        [self.textView endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onTweet:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{@"status" : self.textView.text}];
    
    if (self.inReplyToTweet) {
        [params addEntriesFromDictionary:@{@"in_reply_to_status_id" : self.inReplyToTweet.id}];
    }
    
    [[TwitterClient sharedInstance] postTweetWithParams:params completion:^(id responseObject, NSError *error) {
        if (error) {
            return;
        }
        
        Tweet *postedTweet = [[Tweet alloc] initWithDictionary:responseObject];
        [self.delegate composeViewController:self didSuccessfullyComposeTweet:postedTweet];
        
        [self.textView endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)setNavigationBar {
    //self.navigationController.navigationBar.barTintColor = self.myNavigationBar.barTintColor;
    self.navigationController.navigationBar.titleTextAttributes = self.myNavigationBar.titleTextAttributes;
    self.navigationItem.title = self.myNavigationBar.topItem.title;
    //self.navigationItem.leftBarButtonItem = self.myNavigationBar.topItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onCancel)];
    self.navigationItem.rightBarButtonItem = self.myNavigationBar.topItem.rightBarButtonItem;
    
    self.counterLabel.text = [NSString stringWithFormat:@"%d", MAX_LENGTH];
    
    self.tweetButton.enabled = NO;
    self.tweetButton.alpha = 0.5f;
}

@end
