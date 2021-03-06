//
//  GPRZipTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRZipTransform.h"
#import <GPFoundation/GPFoundation.h>

#import "GPRZipTransformGroup.h"
#import "GPRNode+Private.h"
#import "GPRSenderList.h"
#import "GPREmpty.h"

@implementation GPRZipTransform

- (instancetype) init
{
    if (self = [super init]) {
        _nextQueue = [GPSQueue new];
        [super setName:@"Zip"];
    }
    return self;
}

- (void) next:(id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    [_nextQueue enqueue:value];
    
    if (!self.group) {
        return;
    }
    
    id nextValue = [self.group nextValue];
    if (nextValue != GPREmpty.empty) {
        [super next:nextValue from:senderList context:context];
    }
}

- (void) setFrom:(GPRNode *)from
{
    [super setFrom:from];
    [self breakLinkingIfNeeded];
}

- (void) setTo:(GPRNode *)to
{
    [super setTo:to];
    [self breakLinkingIfNeeded];
}

- (void) breakLinkingIfNeeded
{
    if (self.from == nil && self.to == nil) {
        [self.group removeTransform:self];
    }
}

@end
