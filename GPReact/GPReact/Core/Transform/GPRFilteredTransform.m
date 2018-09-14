//
//  GPRFilteredTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRFilteredTransform.h"
#import "GPRNode+Private.h"

@implementation GPRFilteredTransform
{
@private
    GPRFilterBlock _block;
}

- (instancetype)initWithFilterBlock:(GPRFilterBlock)block
{
    if (self = [super init]) {
        _block = block;
        [super setName:@"Filter"];
    }
    return self;
}

- (void)next:(id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    if (_block && _block(value)) {
        [super next:value from:senderList context:context];
    }
}

@end
