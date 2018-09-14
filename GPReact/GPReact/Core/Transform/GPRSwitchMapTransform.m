//
//  GPRSwitchMapTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRSwitchMapTransform.h"
#import "GPRMarcoDefine.h"
#import "GPRMutableNode.h"

@implementation GPRSwitchMapTransform
{
@private
    GPS_LOCK_DEF(_switchDictionaryLock);
    NSMutableDictionary *_switchDictionary;
    GPRSwitchMapBlock _switchMapBlock;
}

- (instancetype) initWithSwitchMapBlock:(GPRSwitchMapBlock)block
{
    NSParameterAssert(block);
    if (self = [super init]) {
        GPS_LOCK_INIT(_switchDictionaryLock);
        _switchDictionary = [NSMutableDictionary dictionary];
        _switchMapBlock = block;
        [super setName:@"SwitchMap"];
    }
    
    return self;
}

- (void) setFrom:(GPRNode *)from
{
    if (self.from != from) {
        GPS_SCOPE_LOCK(_switchDictionaryLock);
        [_switchDictionary removeAllObjects];
    }
    
    [super setFrom:from];
}

- (void) next:(id)value from:(GPRSenderList *)senderList context:(id)context
{
    if (_switchMapBlock) {
        GPTuple2<id<NSCopying>, id> *mappedResult = _switchMapBlock(value);
        GPTupleUnpack(id<NSCopying> key, id mappedValue, GPT_FromVar(mappedResult));
        if (key == nil) {
            key = [NSNull null];
        }
        
        GPRMutableNode *valueNode = nil;
        {
            GPS_SCOPE_LOCK(_switchDictionaryLock);
            valueNode = _switchDictionary[key];
            
            if (valueNode == nil) {
                valueNode = [GPRMutableNode new];
                _switchDictionary[key] = valueNode;
            }
        }
        
        [valueNode setValue:mappedValue context:context];
        [super next:GPTuple(key, valueNode) from:senderList context:context];
    }
}

@end
