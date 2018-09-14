//
//  GPRScanTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRScanTransform.h"
#import "GPRMarcoDefine.h"

@interface GPRScanTransform()
{
    id _startValue;
    
    GPRReduceWithIndexBlock _reduceBlock;
    GPS_LOCK_DEF(_reduceLock);
}

@property (atomic, strong) id runningValue;
@property (atomic, assign) NSUInteger index;

@end

@implementation GPRScanTransform

- (instancetype) initWithStartValue:(id)startValue reduceBlock:(GPRReduceWithIndexBlock)block
{
    NSParameterAssert(block);
    if (self = [super init]) {
        _startValue = startValue;
        _reduceBlock = [block copy];
        
        _index = 0;
        _runningValue = _startValue;
        
        GPS_LOCK_INIT(_reduceLock);
        [super setName:@"Scan"];
    }
    
    return self;
}

- (void) next:(id)value from:(GPRSenderList *)senderList context:(id)context
{
    id from = self.from;
    BOOL canSend = ({
        GPS_SCOPE_LOCK(_reduceLock);
        !!_reduceBlock;
    });
    
    if (canSend && from == self.from) {
        self.runningValue = _reduceBlock(self.runningValue, value, self.index++);
        [super next:_runningValue from:senderList context:context];
    }
}

- (void) setFrom:(GPRNode *)from
{
    if (self.from != from) {
        GPS_SCOPE_LOCK(_reduceLock);
        self.runningValue = _startValue;
        self.index = 0;
    }
    
    [super setFrom:from];
}

@end
