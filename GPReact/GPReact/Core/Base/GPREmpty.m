//
//  GPREmpty.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPREmpty.h"

@implementation GPREmpty

static GPREmpty *empty = nil;

+ (instancetype) empty
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        empty = [GPREmpty new];
    });
    
    return empty;
}

- (NSString *) description
{
    return @"GPREmpty()";
}

- (instancetype) init
{
    @synchronized([self class]) {
        if (empty) {
            self = empty;
        } else {
            self = [super init];
        }
    }
    
    return self;
}

@end
