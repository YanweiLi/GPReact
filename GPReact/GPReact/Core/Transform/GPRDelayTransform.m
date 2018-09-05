//
//  GPRDelayTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRDelayTransform.h"
#import "GPRMarcoDefine.h"

@implementation GPRDelayTransform
{
    NSTimeInterval _delayTimeInterval;
    dispatch_queue_t _queue;
}

- (instancetype) initWithDelay:(NSTimeInterval)timeInterval
                         queue:(nonnull dispatch_queue_t)queue
{
    NSParameterAssert(timeInterval > 0);
    NSParameterAssert(queue);
    
    if (self = [super init]) {
        _delayTimeInterval = timeInterval;
        _queue = queue;
        [super setName:@"Delay"];
    }
    
    return self;
}

- (void) next:(id)value
         from:(GPRSenderList *)senderList
      context:(nullable id)context
{
    @GPRWeakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayTimeInterval * NSEC_PER_SEC)), _queue, ^{
        @GPRStrongify(self);
        if (self) {
            [super next:value from:senderList context:context];
        }
    });
}

@end
