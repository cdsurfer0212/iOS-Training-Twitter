//
//  Tweet.m
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.mediaArray = [Media mediasWithArray:[dictionary  valueForKeyPath:@"entities.media"]];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.id = dictionary[@"id"];
        self.text = dictionary[@"text"];
        
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        
        self.createdAt = [formatter dateFromString:createdAtString];

        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        self.favoriteCount = @([dictionary[@"favorite_count"] intValue]);
        self.retweetCount = @([dictionary[@"retweet_count"] intValue]);

        if (dictionary[@"retweeted_status"]) {
            self.retweetedTweet = [[Tweet alloc] initWithDictionary: dictionary[@"retweeted_status"]];
        }
    }
    
    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

- (void)updateFavorite:(BOOL)favorited {
    self.favorited = favorited;
    if (favorited) {
        NSNumber *favoriteCount = [NSNumber numberWithInt:[self.favoriteCount intValue] + 1];
        self.favoriteCount = favoriteCount;
    }
    else {
        if (self.favoriteCount.integerValue > 0) {
            NSNumber *favoriteCount = [NSNumber numberWithInt:[self.favoriteCount intValue] - 1];
            self.favoriteCount = favoriteCount;
        }
    }
}

- (void)updateRetweet:(BOOL)retweeted {
    self.retweeted = retweeted;
    if (retweeted) {
        NSNumber *retweetCount = [NSNumber numberWithInt:[self.retweetCount intValue] + 1];
        self.retweetCount = retweetCount;
    }
    else {
        if (self.retweetCount.integerValue > 0) {
            NSNumber *retweetCount = [NSNumber numberWithInt:[self.retweetCount intValue] - 1];
            self.retweetCount = retweetCount;
        }
    }
}

@end
