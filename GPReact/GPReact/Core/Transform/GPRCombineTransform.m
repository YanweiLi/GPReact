//
//  GPRCombineTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRCombineTransform.h"
#import "GPRCombineTransformGroup.h"
#import "GPRNode+Private.h"
#import "GPREmpty.h"

#import <GPFoundation/GPFoundation.h>

@interface GPRCombineTransform ()
@property (atomic, readwrite, strong) id lastValue;
@end

@implementation GPRCombineTransform

- (instancetype) init
{
    if (self = [super init]) {
        _lastValue = GPREmpty.empty;
        [super setName:@"Combine"];
    }
    return self;
}

- (void) next:(id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    self.lastValue = value;
    
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
