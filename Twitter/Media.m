//
//  Media.m
//  Twitter
//
//  Created by Sean Zeng on 7/1/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import "Media.h"

@implementation Media

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.id = dictionary[@"id"];
        self.mediaUrl = dictionary[@"media_url"];
        self.url = dictionary[@"url"];
        self.sizeDictionary = dictionary[@"sizes"];
    }
    return self;
}

+ (NSArray *)mediasWithArray:(NSArray *)array {
    NSMutableArray *medias = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [medias addObject:[[Media alloc] initWithDictionary:dictionary]];
    }
    
    return medias;
}


@end
