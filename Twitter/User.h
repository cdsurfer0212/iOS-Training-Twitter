//
//  User.h
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileBannerUrl;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic) BOOL protected;
@property (nonatomic, strong) NSString *tagline;

@property (nonatomic, strong) NSNumber *followersCount;
@property (nonatomic, strong) NSNumber *followingCount;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;

+ (void)logout;

+ (NSMutableArray *)validAccounts;
+ (void)addValidAccount:(User *)validAccount;

@end
