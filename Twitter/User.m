//
//  User.m
//  Twitter
//
//  Created by Sean Zeng on 6/26/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.id = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileBannerUrl = dictionary[@"profile_banner_url"];
        self.profileImageUrl = dictionary[@"profile_image_url"];
        self.profileImageUrl = [self.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
        //NSLog(@"%@", self.profileImageUrl);
        self.protected = [dictionary[@"protected"] boolValue];
        self.tagline = dictionary[@"description"];
        
        self.followersCount = dictionary[@"followers_count"];
        self.followingCount = dictionary[@"friends_count"];
    }
    
    return self;
}

static User *_currentUser = nil;

NSString * const kCurrentUserKey = @"kCurrentUserKey";

+ (User *)currentUser {
    if (_currentUser == nil) {
        NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

static NSMutableArray *_validAccounts = nil;

NSString * const kValidAccounts = @"kValidAccounts";

+ (NSMutableArray *)validAccounts {
    if (_validAccounts == nil) {
        NSData *dataArrayData = [[NSUserDefaults standardUserDefaults] objectForKey:kValidAccounts];
        if (dataArrayData != nil) {
            NSMutableArray *dataArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataArrayData];
            for (int i = 0; i < dataArray.count; i++) {
                NSData *data = [dataArray objectAtIndex:i];
                if (data != nil) {
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                    User *user = [[User alloc] initWithDictionary:dictionary];
                    [_validAccounts addObject:user];
                }
            }
        }
    }
    
    return _validAccounts;
}

+ (void)addValidAccount:(User *)validAccount {
    for (int i = 0; i < _validAccounts.count; i++) {
        User *user = (User *)[_validAccounts objectAtIndex:i];
        if (validAccount.id == user.id) {
            [_validAccounts removeObjectAtIndex:i];
        }
    }
    
    if (validAccount != nil) {
    if (_validAccounts == nil) {
        _validAccounts = [[NSMutableArray alloc] init];
    }
    
    [_validAccounts insertObject:validAccount atIndex:0];
    }
    
    if (_validAccounts != nil) {
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < _validAccounts.count; i++) {
            User *user = (User *)[_validAccounts objectAtIndex:i];
            NSData *data = [NSJSONSerialization dataWithJSONObject:user.dictionary options:0 error:NULL];
            [dataArray addObject:data];
        }

        [[NSUserDefaults standardUserDefaults] setObject:dataArray forKey:kValidAccounts];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kValidAccounts];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
