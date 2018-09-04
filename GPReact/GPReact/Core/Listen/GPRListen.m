//
//  GPRListen.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRListen.h"
#import "GPRMarcoDefine.h"
#import "GPRNode+Private.h"
#import "GPRSenderList.h"


@implementation GPRListen
{
    GPRNode         *_from;
    __weak GPRNode  *_to;
    
    GPS_LOCK_DEF(_fromLock);
    GPS_LOCK_DEF(_toLock);
}

@synthesize name = _name;

- (instancetype) init
{
    if (self = [super init]) {
        _name = @"Listen";
        GPS_LOCK_INIT(_fromLock);
        GPS_LOCK_INIT(_toLock);
    }
    
    return self;
}

- (void) next:(id)value
         from:(GPRSenderList *)senderList
      context:(nullable id)context
{
    NSAssert(0, @"should be hanlded by subClass!!!");
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
        _to = to;
    }
    
    [self pushValueIfNeeded];
}

- (void) setFrom:(GPRNode *)from
{
    {
        GPS_SCOPE_LOCK(_fromLock);
        GPRNode *lastFrom = _from;
        if (lastFrom) {
            [lastFrom removeListenEdge:self];
            _from = nil;
        }
        
        if (!from) {
            return;
        }
        
        _from = from;
        [_from addListenEdge:self];
    }
    
    [self pushValueIfNeeded];
}

- (void) pushValueIfNeeded
{
    if (self.from && self.to && (!self.from.isEmpty)) {
        [self next:self.from.value from:[GPRSenderList senderListWithSender:self.from] context:nil];
    }
}

- (void) dealloc
{
    if (_from) {
        [_from removeListenEdge:self];
    }
}

@end
