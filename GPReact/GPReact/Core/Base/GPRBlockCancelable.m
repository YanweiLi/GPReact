//
//  GPRBlockCancelable.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRBlockCancelable.h"


@implementation GPRBlockCancelable
{
    GPRCancelBlockType _block;
}

- (instancetype) initWithBlock:(GPRCancelBlockType)block
{
    NSParameterAssert(block);
    if (self = [super init]) {
        _block = [block copy];
    }
    return self;
}

- (void) cancel
{
    GPRCancelBlockType block = nil;
    
    @synchronized(self) {
        block = _block;
        _block = nil;
    }
    
    if (block) {
        block();
    }
}

@end

