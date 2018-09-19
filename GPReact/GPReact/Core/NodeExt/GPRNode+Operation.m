//
//  GPRNode+Operation.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode+Operation.h"

// block
#import "GPRBlockCancelable.h"
#import "GPREmpty.h"
#import "GPRNode+Private.h"
#import "GPRSenderList.h"

// transform
#import "GPRMapTransform.h"
#import "GPRDelayTransform.h"
#import "GPRDeliverTransform.h"
#import "GPRFilteredTransform.h"
#import "GPRDistinctTransform.h"
#import "GPRFlattenTransform.h"
#import "GPRThrottleTransform.h"
#import "GPRZipTransform.h"
#import "GPRZipTransformGroup.h"
#import "GPRCombineTransform.h"
#import "GPRCombineTransformGroup.h"
#import "GPRTakeTransform.h"
#import "GPRSkipTransform.h"
#import "GPRScanTransform.h"
#import "GPRSwitchMapTransform.h"
#import "GPRCaseTransform.h"

NSString * const GPRExceptionReason_SyncTransformBlockAndRevertNotInverseOperations
= @"GPRExceptionReason_SyncTransformBlockAndRevertNotInverseOperations";

NSString * const GPRExceptionReason_FlattenOrFlattenMapNextValueNotGPRNode
= @"GPRExceptionReason_FlattenOrFlattenMapNextValueNotGPRNode";

NSString * const GPRExceptionReason_MapEachNextValueNotTuple
= @"GPRExceptionReason_MapEachNextValueNotTuple";

NSString * const GPRExceptionReason_CasedNodeMustGenerateBySwitchOrSwitchMapOperation
= @"GPRExceptionReason_CasedNodeMustGenerateBySwitchOrSwitchMapOperation";

@implementation GPRNode (Operation)

- (GPRNode *) fork
{
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self];
    return returnedNode;
}

- (GPRNode *) map:(GPRMapBlock)block
{
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:[[GPRMapTransform alloc] initWithMapBlock:block]];
    return returnedNode;
}

- (GPRNode *) filter:(GPRFilterBlock)block
{
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:[[GPRFilteredTransform alloc] initWithFilterBlock:block]];
    return returnedNode;
}

- (GPRNode *) skip:(NSUInteger)number
{
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:[[GPRSkipTransform alloc] initWithNumber:number]];
    return returnedNode;
}

- (GPRNode *) take:(NSUInteger)number
{
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:[[GPRTakeTransform alloc] initWithNumber:number]];
    return returnedNode;
}

- (GPRNode *) ignore:(id)ignoreValue
{
    return [self filter:^BOOL(id  _Nullable next) {
        return !(ignoreValue == next || [ignoreValue isEqual:next]);
    }];
}

- (GPRNode *) select:(id)selectedValue
{
    return [self filter:^BOOL(id  _Nullable next) {
        return selectedValue == next || [selectedValue isEqual:next];
    }];
}

- (GPRNode *) then:(void(NS_NOESCAPE ^)(GPRNode<id> *node))thenBlock
{
    NSParameterAssert(thenBlock);
    if (thenBlock) {
        thenBlock(self);
    }
    return self;
}

- (GPRNode *) mapReplace:(id)mappedValue
{
    return [self map:^id _Nullable(id  _Nullable next) {
        return  mappedValue;
    }];
}

- (GPRNode*) deliverOn:(dispatch_queue_t)queue
{
    NSParameterAssert(queue);
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:[[GPRDeliverTransform alloc] initWithQueue:queue]];
    return returnedNode;
}

- (GPRNode *) deliverOnMainQueue
{
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:[[GPRDeliverTransform alloc] initWithQueue:dispatch_get_main_queue()]];
    return returnedNode;
}

- (GPRNode *) distinctUntilChanged
{
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:GPRDistinctTransform.new];
    return returnedNode;
}

- (GPRNode *) flattenMap:(GPRFlattenMapBlock)block
{
    GPRNode *returnedNode = GPRNode.new;
    GPRFlattenTransform *transform = [[GPRFlattenTransform alloc] initWithBlock:block];
    [returnedNode linkTo:self transform:transform];
    return returnedNode;
}

- (GPRNode *) flatten
{
    GPRNode *returnedNode = GPRNode.new;
    GPRFlattenTransform *transform = [[GPRFlattenTransform alloc] initWithBlock:^GPRNode * _Nullable(id  _Nullable value) {
        return value;
    }];
    [returnedNode linkTo:self transform:transform];
    return returnedNode;
}

- (GPRNode *) throttleOnMainQueue:(NSTimeInterval)timeInterval
{
    NSParameterAssert(timeInterval > 0);
    return [self throttle:timeInterval queue:dispatch_get_main_queue()];
}

- (GPRNode *) throttle:(NSTimeInterval)timeInterval
                 queue:(dispatch_queue_t)queue
{
    NSParameterAssert(timeInterval > 0);
    NSParameterAssert(queue);
    GPRNode *returnedNode = GPRNode.new;
    GPRThrottleTransform *transform = [[GPRThrottleTransform alloc] initWithThrottle:timeInterval on:queue];
    [returnedNode linkTo:self transform:transform];
    return returnedNode;
}

- (GPRNode *) delay:(NSTimeInterval)timeInterval
              queue:(dispatch_queue_t)queue
{
    NSParameterAssert(timeInterval > 0);
    NSParameterAssert(queue);
    GPRNode *returnedNode = GPRNode.new;
    GPRDelayTransform *transform = [[GPRDelayTransform alloc] initWithDelay:timeInterval queue:queue];
    [returnedNode linkTo:self transform:transform];
    return returnedNode;
}

- (GPRNode *) delayOnMainQueue:(NSTimeInterval)timeInterval
{
    NSParameterAssert(timeInterval > 0);
    return [self delay:timeInterval queue:dispatch_get_main_queue()];
}

- (id<GPRCancelable>) syncWith:(GPRNode *)othGPRNode
                     transform:(id  _Nonnull (^)(id _Nonnull))transform
                        revert:(id  _Nonnull (^)(id _Nonnull))revert
{
    NSParameterAssert(transform);
    NSParameterAssert(revert);
    GPRMapTransform *mapTransform = [[GPRMapTransform alloc] initWithMapBlock:transform];
    GPRMapTransform *mapRevert = [[GPRMapTransform alloc] initWithMapBlock:revert];
    
    id<GPRCancelable> transformCancelable = [self linkTo:othGPRNode transform:mapTransform];
    id<GPRCancelable> revertCancelable = [othGPRNode linkTo:self transform:mapRevert];
    return [[GPRBlockCancelable alloc] initWithBlock:^{
        [transformCancelable cancel];
        [revertCancelable cancel];
    }];
}

- (id<GPRCancelable>) syncWith:(GPRNode *)othGPRNode
{
    id (^idFunction)(id) = ^(id source) { return source; };
    return [self syncWith:othGPRNode transform:idFunction revert:idFunction];
}

- (GPRNode *) scanWithStart:(id)startingValue
                     reduce:(GPRReduceBlock)reduceBlock
{
    NSParameterAssert(reduceBlock);
    GPRReduceWithIndexBlock block = ^id _Nonnull(id  _Nullable runningValue, id  _Nullable next, NSUInteger index) {
        if (reduceBlock) {
            return reduceBlock(runningValue, next);
        }
        return nil;
    };
    return [self scanWithStart:startingValue reduceWithIndex:block];
}

- (GPRNode *) scanWithStart:(id)startingValue
            reduceWithIndex:(GPRReduceWithIndexBlock)reduceBlock
{
    NSParameterAssert(reduceBlock);
    GPRNode *returnedNode = GPRNode.new;
    [returnedNode linkTo:self transform:[[GPRScanTransform alloc] initWithStartValue:startingValue reduceBlock:reduceBlock]];
    return returnedNode;
}

+ (GPRNode *) merge:(NSArray<GPRNode *> *)nodes
{
    NSParameterAssert(nodes);
    GPRNode *returnedNode = GPRNode.new;
    [GP_NEW_SEQ(nodes) forEach:^(GPRNode * _Nonnull value) {
        [returnedNode linkTo:value];
    }];
    return returnedNode;
}

- (GPRNode *) merge:(GPRNode *)node
{
    NSParameterAssert(node);
    return [GPRNode merge:@[self, node]];
}

+ (GPRNode<__kindof GPTupleBase *> *) zip:(NSArray<GPRNode *> *)nodes
{
    NSParameterAssert(nodes);
    GPRNode *returnedNode = GPRNode.new;
    
    NSArray<GPRZipTransform *> *zipTransforms = [[GP_NEW_SEQ(nodes) map:^id _Nonnull(GPRNode * _Nonnull value) {
        GPRZipTransform *transform = [GPRZipTransform new];
        [returnedNode linkTo:value transform:transform];
        return transform;
    }] as:NSArray.class] ;
    
    GPRZipTransformGroup *group = [[GPRZipTransformGroup alloc] initWithTransforms:zipTransforms];
    
    id nextValue = [group nextValue];
    if (nextValue != GPREmpty.empty) {
        GPRSenderList *senderList = [GPRSenderList senderListWithArray:nodes];
        [returnedNode next:nextValue from:senderList context:nil];
    }
    
    return returnedNode;
}

- (GPRNode *) zip:(GPRNode *)node
{
    NSParameterAssert(node);
    return [GPRNode zip:@[self, node]];
}

+ (GPRNode<__kindof GPTupleBase *> *) combine:(NSArray<GPRNode *> *)nodes
{
    NSParameterAssert(nodes);
    GPRNode *returnedNode = GPRNode.new;
    
    NSArray<GPRCombineTransform *> *combineTransforms = [[GP_NEW_SEQ(nodes) map:^id _Nonnull(GPRNode * _Nonnull node) {
        GPRCombineTransform *transform = [GPRCombineTransform new];
        [returnedNode linkTo:node transform:transform];
        return transform;
    }] as:NSArray.class];
    
    GPRCombineTransformGroup *group = [[GPRCombineTransformGroup alloc] initWithTransforms:combineTransforms];
    
    id nextValue = [group nextValue];
    if (nextValue != GPREmpty.empty) {
        GPRSenderList *senderList = [GPRSenderList senderListWithArray:nodes];
        [returnedNode next:nextValue from:senderList context:nil];
    }
    
    return returnedNode;
}

- (GPRNode *) combine:(GPRNode *)node
{
    NSParameterAssert(node);
    return [GPRNode combine:@[self, node]];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GPRNode (SwitchCase)

- (GPRNode<GPRSwitchedNodeTuple<id> *> *)switch:(id<NSCopying>  _Nullable (^)(id _Nullable))switchBlock {
    NSParameterAssert(switchBlock);
    return [self switchMap:^GPTuple2<id<NSCopying>,id> * _Nonnull(id  _Nullable next) {
        return GPRSwitchedNodeTupleMake(switchBlock(next), next);
    }];
}

- (GPRNode<GPRSwitchedNodeTuple<id> *> *)switchMap:(GPTuple2<id<NSCopying>,id> * _Nonnull (^)(id _Nullable))switchMapBlock {
    NSParameterAssert(switchMapBlock);
    GPRSwitchMapTransform *transform = [[GPRSwitchMapTransform alloc] initWithSwitchMapBlock:switchMapBlock];
    GPRNode *returnedNode = [GPRNode new];
    [returnedNode linkTo:self transform:transform];
    return returnedNode;
}

- (GPRNode *)case:(nullable id<NSCopying>)key {
    GPRCaseTransform *transform = [[GPRCaseTransform alloc] initWithCaseKey:key];
    GPRNode *returnedNode = [GPRNode new];
    [returnedNode linkTo:self transform:transform];
    return returnedNode;
}

- (GPRNode *)default {
    return [self case:nil];
}

- (GPRIFResult *)if:(BOOL (^)(id _Nullable next))block {
    NSParameterAssert(block);
    GPRNode<GPRSwitchedNodeTuple<id> *> *switchedNode = [self switch:^id<NSCopying> _Nonnull(id  _Nullable next) {
        return @(block(next));
    }];
    return GPRIFResultMake([switchedNode case:@YES], [switchedNode case:@NO]);
}

@end

_GPTNamedTupleImp(GPRIFResult)
_GPTNamedTupleImp(GPRSwitchedNodeTuple)

@implementation GPRIFResult (Extension)

- (GPRIFResult *)then:(void (NS_NOESCAPE^)(GPRNode<id> * _Nonnull))thenBlock {
    NSParameterAssert(thenBlock);
    if (thenBlock) {
        thenBlock(self.thenNode);
    }
    return self;
}

- (GPRIFResult *)else:(void (NS_NOESCAPE^)(GPRNode<id> * _Nonnull))elseBlock {
    NSParameterAssert(elseBlock);
    if (elseBlock) {
        elseBlock(self.elseNode);
    }
    return self;
}

@end
