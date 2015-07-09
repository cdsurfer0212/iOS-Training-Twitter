//
//  AccountCell.m
//  Twitter
//
//  Created by Sean Zeng on 7/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "AccountCell.h"
#import <UIImageView+AFNetworking.h>

@interface AccountCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

@end

@implementation AccountCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Custom setters

- (void)setUser:(User *)user{
    _user = user;
    [self initializeLayout];
}

- (void)initializeLayout {
    self.nameLabel.text = self.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];

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
                    //self.blurredHeaderImageView.image = [self.headerImageView.image blurredImageWithRadius:10.0 iterations:20.0 tintColor:nil];
                }
            ];
        }
        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"%@", error);
        }
    ];
}

@end
