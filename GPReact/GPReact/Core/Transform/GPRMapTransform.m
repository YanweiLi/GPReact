//
//  GPRMapTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRMapTransform.h"
#import "GPRNode+Private.h"

@implementation GPRMapTransform
{
@private
    GPRMapBlock _block;
}

- (instancetype) initWithMapBlock:(GPRMapBlock)block
{
    if (self = [super init]) {
        _block = [block copy];
        [super setName:@"Map"];
    }
    return self;
}

- (void) next:(id)value
         from:(GPRSenderList *)senderList
      context:(nullable id)context
{
    if (_block) {
        [super next:_block(value) from:senderList context:context];
    }
}

@end
