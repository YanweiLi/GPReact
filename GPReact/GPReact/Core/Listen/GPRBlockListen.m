//
//  GPRBlockListen.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRBlockListen.h"

@implementation GPRBlockListen
{
    GPRListenBlockType _block;
}

- (instancetype)initWithBlock:(GPRListenBlockType)block
{
    NSParameterAssert(block);
    if (self = [super init]) {
        _block = [block copy];
    }
    
    return self;
}

- (void)next:(id)value
        from:(GPRSenderList *)senderList
     context:(nullable id)context
{
    if (_block) {
        _block(value, senderList, context);
    }
}

@end
