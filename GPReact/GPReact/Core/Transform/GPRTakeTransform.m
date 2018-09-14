//
//  GPRTakeTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRTakeTransform.h"
#import "GPRMarcoDefine.h"

@implementation GPRTakeTransform
{
    NSUInteger _needTakenTimes;
    NSUInteger _takenTimes;
    GPS_LOCK_DEF(_takenTimesLock);
}

- (instancetype) initWithNumber:(NSUInteger)needTakenTimes
{
    if (self = [super init]) {
        _needTakenTimes = needTakenTimes;
        _takenTimes = 0;
        GPS_LOCK_INIT(_takenTimesLock);
        [super setName:@"Take"];
    }
    
    return self;
}

- (void) next:(id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    id from = self.from;
    BOOL canSend = ({
        GPS_SCOPE_LOCK(_takenTimesLock);
        _takenTimes++ < _needTakenTimes;
    });
    
    if (canSend && from == self.from) {
        [super next:value from:senderList context:context];
    }
}

- (void) setFrom:(GPRNode *)from
{
    if (self.from != from) {
        GPS_SCOPE_LOCK(_takenTimesLock);
        _takenTimes = 0;
    }
    
    [super setFrom:from];
}

@end
