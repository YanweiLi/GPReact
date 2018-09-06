//
//  GPRFlattenTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRFlattenTransform.h"
#import "GPRCancelable.h"
#import "GPRMarcoDefine.h"
#import "GPRNode+Operation.h"
#import "GPRNode+Private.h"
#import "GPRNode+Listen.h"
#import "GPRListenContext.h"

@interface GPRFlattenTransform ()
@property (atomic, strong, readwrite) id<GPRCancelable> cancelable;
@end

@implementation GPRFlattenTransform
{
@private
    GPRFlattenMapBlock _block;
}

- (instancetype) initWithBlock:(GPRFlattenMapBlock)block
{
    NSParameterAssert(block);
    if (self = [super init]) {
        _block = block;
        [super setName:@"Flatten"];
    }
    return self;
}

- (void) setFrom:(GPRNode *)from
{
    if (self.from != from) {
        [self.cancelable cancel];
        self.cancelable = nil;
    }
    
    [super setFrom:from];
}

- (void) next:(id)value
         from:(GPRSenderList *)senderList
      context:(nullable id)context
{
    if (!_block) {
        return;
    }
    
    GPRNode *node = _block(value);
    if (![node isKindOfClass:GPRNode.class]) {
        GPR_THROW(GPRNodeExceptionName, GPRExceptionReason_FlattenOrFlattenMapNextValueNotGPRNode, nil);
    }
    
    [self.cancelable cancel];
    self.cancelable = nil;
    
    @GPRWeakify(self);
    self.cancelable = [[node listenedBy:self] withSenderListAndContextBlock:^(id  _Nullable next
                                                                              , GPRSenderList * _Nonnull insideSenderList
                                                                              , id  _Nullable insideContext)
                       {
                           @GPRStrongify(self);
                           
                           // The first transmit is from high-order node
                           // Transmits will be from current node since the second time
                           if (self.cancelable) {
                               [self _superNext:next from:insideSenderList context:insideContext];
                           }
                       }];
    
    if (!node.isEmpty) {
        [super next:node.value from:[senderList appendNewSender:node] context:context];
    }
}

- (void) _superNext:(id)value
               from:(GPRSenderList *)senderList
            context:(nullable id)context
{
    [super next:value from:senderList context:context];
}

- (void)dealloc
{
    [self.cancelable cancel];
}

@end
