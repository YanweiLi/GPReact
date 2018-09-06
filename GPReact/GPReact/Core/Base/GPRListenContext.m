//
//  GPRListenContext.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRListenContext.h"

// base
#import "GPRBlockCancelable.h"
#import "GPRMarcoDefine.h"

// listen
#import "GPRBlockListen.h"
#import "GPRDeliveredListen.h"

// private
#import "GPRListenContext+Private.h"
#import "GPRNode+Private.h"

// protocol
#import "GPRCancelableBagProtocol.h"
#import "GPRListenEdge.h"

#import "NSObject+GPRListen.h"

@implementation GPRListenContext
{
    __weak GPRNode *_node;
    __weak id _listener;
    NSMutableArray<id<GPRListenEdge>> *_transforms;
}

- (instancetype) initWithNode:(__weak GPRNode *)node
                     listener:(__weak id) listener
{
    if (self = [super init]) {
        _node = node;
        _listener = listener;
        _transforms = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id<GPRCancelable>) withBlock:(void (^)(id _Nullable next))block
{
    NSParameterAssert(block);
    GPRListenBlockType contextBlock = ^(id next, GPRSenderList *senderList, id context) {
        if (block) {
            block(next);
        }
    };
    
    return [self withSenderListAndContextBlock:contextBlock];
}

- (id<GPRCancelable>) withContextBlock:(void (^)(id _Nullable, id _Nullable))block
{
    NSParameterAssert(block);
    if (!block) {
        return [[GPRBlockCancelable alloc] initWithBlock:^{}];
    }
    
    GPRListenBlockType contextBlock = ^(id next, GPRSenderList *senderList, id context) {
        if (block) {
            block(next, context);
        }
    };
    return [self withSenderListAndContextBlock:contextBlock];
}

- (id<GPRCancelable>) withSenderListAndContextBlock:(void (^)(id _Nullable, GPRSenderList * _Nonnull, id _Nullable))block
{
    NSParameterAssert(block);
    GPRBlockListen *handler = [[GPRBlockListen alloc] initWithBlock:block];
    return [self withListenEdge:handler];
}

- (id<GPRCancelable>) withBlock:(void (^)(id _Nullable))block on:(dispatch_queue_t)queue
{
    NSParameterAssert(block);
    NSParameterAssert(queue);
    GPRListenBlockType contextBlock = ^(id next, GPRSenderList *senderList, id context) {
        if (block) {
            block(next);
        }
    };
    return [self withSenderListAndContextBlock:contextBlock on:queue];
}

- (id<GPRCancelable>) withContextBlock:(void (^)(id _Nullable, id _Nullable))block on:(dispatch_queue_t)queue
{
    NSParameterAssert(block);
    NSParameterAssert(queue);
    GPRListenBlockType contextBlock = ^(id next, GPRSenderList *senderList, id context) {
        if (block) {
            block(next, context);
        }
    };
    return [self withSenderListAndContextBlock:contextBlock on:queue];
}

- (id<GPRCancelable>) withSenderListAndContextBlock:(void (^)(id _Nullable next, GPRSenderList *senderList,  id _Nullable context))block on:(dispatch_queue_t)queue
{
    NSParameterAssert(block);
    NSParameterAssert(queue);
    if (block == nil || queue == NULL) {
        return [[GPRBlockCancelable alloc] initWithBlock:^{}];
    }
    
    GPRDeliveredListen *handler = [[GPRDeliveredListen alloc] initWithBlock:block on:queue];
    return [self withListenEdge:handler];
    
}

- (id<GPRCancelable>) withBlockOnMainQueue:(void (^)(id _Nullable))block
{
    return [self withBlock:block on:dispatch_get_main_queue()];
}

- (id<GPRCancelable>) withContextBlockOnMainQueue:(void (^)(id _Nullable, id _Nullable))block
{
    return [self withContextBlock:block on:dispatch_get_main_queue()];
}

- (id<GPRCancelable>) withListenEdge:(id<GPRListenEdge>)listenEdge
{
    NSParameterAssert(listenEdge);
    
    GPRNode *strongNode = _node;
    
    if (listenEdge == nil || strongNode == nil) {
        return [[GPRBlockCancelable alloc] initWithBlock:^{}];
    }
    
    listenEdge.from = strongNode;
    listenEdge.to = _listener;
    [_transforms addObject:listenEdge];
    
    @GPRWeakify(self);
    return [[GPRBlockCancelable alloc] initWithBlock:^{
        @GPRStrongify(self);
        
        listenEdge.from = nil;
        listenEdge.to = nil;
        
        if(self) {
            [self->_transforms removeObject:listenEdge];
            if (self->_transforms.count == 0) {
                [self->_listener stopListen:strongNode];
            }
        }
    }];
}

@end
