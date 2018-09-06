//
//  GPRThrottleTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRThrottleTransform.h"
#import "GPRNode+Private.h"
#import "GPRMarcoDefine.h"

@implementation GPRThrottleTransform
{
@private
    NSTimeInterval _throttleInterval;
    dispatch_source_t _throttleSource;
    dispatch_queue_t _queue;
    GPS_LOCK_DEF(_sourceLock);
}

- (instancetype) initWithThrottle:(NSTimeInterval)timeInterval
                               on:(dispatch_queue_t)queue
{
    NSParameterAssert(timeInterval > 0);
    NSParameterAssert(queue);
    if (self = [super init]) {
        _throttleInterval = timeInterval;
        _queue = queue;
        
        GPS_LOCK_INIT(_sourceLock);
        [super setName:@"Throttle"];
    }
    
    return self;
}

- (void) next:(id)value
         from:(GPRSenderList *)senderList
      context:(nullable id)context
{
    GPS_SCOPE_LOCK(_sourceLock);
    
    if (_throttleSource) {
        dispatch_source_cancel(_throttleSource);
        _throttleSource = nil;
    }
    
    _throttleSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_throttleSource, dispatch_time(DISPATCH_TIME_NOW, _throttleInterval * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0.005);
    
    @GPRWeakify(self)
    dispatch_source_set_event_handler(_throttleSource, ^{
        @GPRStrongify(self)
        if (!self) {
            return ;
        }
        
        GPS_SCOPE_LOCK(self->_sourceLock);
        [self _superNext:value from:senderList context:context];
        
        dispatch_source_cancel(self->_throttleSource);
        self->_throttleSource = nil;
    });
    
    dispatch_resume(_throttleSource);
}

- (void) _superNext:(id)value
               from:(GPRSenderList *)senderList
            context:(nullable id)context
{
    [super next:value from:senderList context:context];
}

@end
