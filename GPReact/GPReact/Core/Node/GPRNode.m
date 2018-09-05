//
//  GPRNode.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"
#import "GPRMutableNode.h"
#import "GPRNode+Private.h"
#import "GPREmpty.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wincomplete-implementation"
@implementation GPRNode

@dynamic value, name, mutable;

// private for subClass
- (instancetype) initDirectly
{
    return [super init];
}

- (instancetype) init
{
    return [self initWithValue:[GPREmpty empty]];
}

- (instancetype) initWithValue:(id)value
{
    return [[GPRMutableNode alloc] initWithValue:value mutable:NO];
}

+ (instancetype) value:(id)value
{
    return [[GPRMutableNode alloc] initWithValue:value mutable:NO];
}
@end

#pragma clang diagnostic pop
