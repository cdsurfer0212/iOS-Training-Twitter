//
//  TwitterClient.h
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion forceLogin:(BOOL)forceLogin;
- (void)openURL:(NSURL *)url;

- (void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)postTweetWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)retweetWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)cancelRetweetWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)favoriteWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)cancelFavoriteWithParams:(NSDictionary *)params completion:(void (^)(id responseObject, NSError *error))completion;
- (void)userTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion;

@end
