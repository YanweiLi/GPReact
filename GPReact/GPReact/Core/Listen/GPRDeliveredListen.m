//
//  GPRDeliveredListen.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRDeliveredListen.h"

@implementation GPRDeliveredListen
{
    dispatch_queue_t _queue;
}

- (instancetype)initWithBlock:(GPRListenBlockType)block
                           on:(dispatch_queue_t)queue
{
    NSParameterAssert(queue);
    if (self = [super initWithBlock:block]) {
        _queue = queue;
    }
    
    return self;
}

- (void)next:(id)value
        from:(GPRSenderList *)senderList
     context:(nullable id)context
{
    if (_queue) {
        dispatch_async(_queue, ^{
            [super next:value from:senderList context:context];
        });
    }
}

@end
