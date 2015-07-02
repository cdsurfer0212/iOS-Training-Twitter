//
//  Media.h
//  Twitter
//
//  Created by Sean Zeng on 7/1/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Media : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *mediaUrl;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *sizeDictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)mediasWithArray:(NSArray *)array;

@end
