//
//  GPRTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRTransform.h"
#import "GPRNode+Private.h"
#import "GPRMarcoDefine.h"
#import "GPRSenderList.h"

@implementation GPRTransform
{
    GPRNode         *_from;
    __weak GPRNode  *_to;
    GPS_LOCK_DEF(_fromLock);
    GPS_LOCK_DEF(_toLock);
}

@synthesize name = _name, nextReceiver = _nextReceiver;

- (instancetype) init
{
    if (self = [super init]) {
        _name = @"Link";
        GPS_LOCK_INIT(_fromLock);
        GPS_LOCK_INIT(_toLock);
    }
    
    return self;
}

- (void) next:(nullable id)value
         from:(GPRSenderList *)senderList
      context:(nullable id)context
{
    [self.nextReceiver next:value from:senderList context:context];
}

- (GPRNode *) to
{
    GPS_SCOPE_LOCK(_toLock);
    return _to;
}

- (GPRNode *) from
{
    GPS_SCOPE_LOCK(_fromLock);
    return _from;
}

- (void) setTo:(GPRNode *)to
{
    {
        GPS_SCOPE_LOCK(_toLock);
        GPRNode *lastTo = _to;
        if (lastTo) {
            [lastTo removeUpstreamTransformData:self];
            _to = nil;
            _nextReceiver = nil;
        }
        
        if (!to) {
            return;
        }
        
        _to = to;
        _nextReceiver = [_to addUpstreamTransformData:self];
    }
    
    [self pushValueIfNeeded];
}

- (void) setFrom:(GPRNode *)from
{
    {
        GPS_SCOPE_LOCK(_fromLock);
        GPRNode *lastFrom = _from;
        if (lastFrom) {
            [lastFrom removeDownstreamTransformData:self];
            _from = nil;
        }
        
        if (!from) {
            return;
        }
        
        _from = from;
        [_from addDownstreamTransformData:self];
    }
    
    [self pushValueIfNeeded];
}

- (void) pushValueIfNeeded
{
    if (self.from && self.nextReceiver && (!self.from.isEmpty)) {
        [self next:self.from.value from:[GPRSenderList senderListWithSender:self.from] context:nil];
    }
}

- (void) dealloc
{
    if (_from) {
        [_from removeDownstreamTransformData:self];
    }
    
    if (_to) {
        [_to removeUpstreamTransformData:self];
    }
}

@end
