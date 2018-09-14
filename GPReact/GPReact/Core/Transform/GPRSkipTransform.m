//
//  GPRSkipTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRSkipTransform.h"
#import "GPRMarcoDefine.h"

@implementation GPRSkipTransform
{
    NSUInteger _skippedTimes;
    NSUInteger _needSkipTimes;
    GPS_LOCK_DEF(_skipedTimesLock);
}

- (instancetype) initWithNumber:(NSUInteger)needSkipTimes
{
    if (self = [super init]) {
        _needSkipTimes = needSkipTimes;
        _skippedTimes = 0;
        
        GPS_LOCK_INIT(_skipedTimesLock);
        [super setName:@"Skip"];
    }
    
    return self;
}

- (void) next:(id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    id from = self.from;
    BOOL canSend = ({
        GPS_SCOPE_LOCK(_skipedTimesLock);
        ++_skippedTimes > _needSkipTimes;
    });
    
    if (canSend && from == self.from) {
        [super next:value from:senderList context:context];
    }
}

- (void) setFrom:(GPRNode *)from
{
    if (self.from != from) {
        GPS_SCOPE_LOCK(_skipedTimesLock);
        _skippedTimes = 0;
    }
    
    [super setFrom:from];
}

@end
