//
//  GPRCaseTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRCaseTransform.h"
#import "GPRMarcoDefine.h"
#import "GPRNode+Listen.h"

@interface GPRCaseTransform ()
@property (atomic, strong) GPRNode *lastNode;
@property (atomic, strong) id<GPRCancelable> cancelable;
@end

@implementation GPRCaseTransform
{
    id<NSCopying> _key;
}

- (instancetype) initWithCaseKey:(id<NSCopying>)key
{
    if (self = [super init]) {
        _key = key;
        [super setName:@"Case"];
    }
    return self;
}

static BOOL GPR_instanceEqual(id left, id right)
{
    if (left == right) { return YES; }
    if ([left respondsToSelector:@selector(isEqual:)]) {
        return [left isEqual:right];
    }
    
    if ([right respondsToSelector:@selector(isEqual:)]) {
        return [right isEqual:left];
    }
    
    return NO;
}

- (void) next:(GPTuple2<id<NSCopying>, GPRNode *> *)next
         from:(GPRSenderList *)senderList
      context:(id)context
{
    BOOL canCase = gps_isKindOf(GPTuple2)(next)
    && [[(id)next.first class] conformsToProtocol:@protocol(NSCopying)]
    && gps_isKindOf(GPRNode)(next.second);
    
    if (!canCase) {
        GPR_THROW(GPRNodeExceptionName, GPRExceptionReason_CasedNodeMustGenerateBySwitchOrSwitchMapOperation, nil);
    }
    
    id nextKey = next.first;
    nextKey = GPR_instanceEqual(nextKey, NSNull.null) ? nil : nextKey;
    
    if (GPR_instanceEqual(nextKey, _key)) {
        if (next.second == self.lastNode) {
            return ;
        }
        
        [self.cancelable cancel];
        self.cancelable = nil;
        self.lastNode = next.second;
        
        @GPRWeakify(self)
        self.cancelable = [[next.second listenedBy:self] withSenderListAndContextBlock:^(id  _Nullable value
                                                                                         , GPRSenderList * _Nonnull insideSenderList
                                                                                         , id  _Nullable insideContext) {
            @GPRStrongify(self)
            if (self.cancelable) {
                [self _superNext:value from:insideSenderList context:insideContext];
            }
        }];
        
        if (!next.second.isEmpty) {
            [super next:next.second.value from:[senderList appendNewSender:next.second] context:context];
        }
    }
}

- (void) _superNext:(id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    [super next:value from:senderList context:context];
}

@end
