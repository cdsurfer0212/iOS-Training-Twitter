//
//  Tweet.h
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Media.h"
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSArray *mediaArray;
@property (nonatomic, strong) User *user;

@property (nonatomic) BOOL favorited;
@property (nonatomic, strong) NSNumber *favoriteCount;

@property (nonatomic) BOOL retweeted;
@property (nonatomic, strong) NSNumber *retweetCount;

@property (nonatomic, strong) Tweet *retweetedTweet;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

- (void)updateFavorite:(BOOL)favorited;
- (void)updateRetweet:(BOOL)retweeted;

@end
