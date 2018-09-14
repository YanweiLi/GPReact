//
//  GPRDeliverTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRDeliverTransform.h"
#import "GPRMarcoDefine.h"

@implementation GPRDeliverTransform
{
    dispatch_queue_t _queue;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        NSParameterAssert(queue);
        _queue = queue;
    }
    
    return self;
}

- (void) next:(id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    if (_queue) {
        @GPRWeakify(self);
        dispatch_async(_queue, ^{
            @GPRStrongify(self);
            if (self) {
                [super next:value from:senderList context:context];
            }
        });
    }
}

@end
