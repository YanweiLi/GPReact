//
//  NSObject+GPRListen.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "NSObject+GPRListen.h"
#import "GPRListenContext+Private.h"
#import "GPRNode.h"
#import <objc/runtime.h>

static void *GPR_NodeContextKey = &GPR_NodeContextKey;
typedef NSMutableDictionary<NSString *, GPRListenContext *> NodeContext;

@interface NSObject (GPRListenPrivate)
@property (atomic, strong)  NodeContext *nodeContext;
@end

@implementation NSObject (GPRListen)

- (GPRListenContext *) listen:(GPRNode *)node
{
    NSParameterAssert(node);
    if (!node) {
        return nil;
    }
    
    NodeContext *nodeContext = self.nodeContext;
    @synchronized(self) {
        NSString *uniqueKey = [NSString stringWithFormat:@"%p", node];
        GPRListenContext *context = nodeContext[uniqueKey];
        if (!context) {
            context = [[GPRListenContext alloc] initWithNode:node listener:self] ;
            nodeContext[uniqueKey] = context;
        }
        
        return context;
    }
}

- (void) stopListen:(GPRNode *)node
{
    NSMutableDictionary<NSString *, GPRListenContext *> *nodeContext = self.nodeContext;
    @synchronized(self) {
        NSString *uniqueKey = [NSString stringWithFormat:@"%p", node];
        nodeContext[uniqueKey] = nil;
    }
}

- (NodeContext*) nodeContext
{
    NodeContext *nodeContext = objc_getAssociatedObject(self, GPR_NodeContextKey);
    
    if (!nodeContext) {
        @synchronized(self) {
            nodeContext = objc_getAssociatedObject(self, GPR_NodeContextKey);
            if (!nodeContext) {
                nodeContext = [[NSMutableDictionary alloc] init];
                objc_setAssociatedObject(self, GPR_NodeContextKey, nodeContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    
    return nodeContext;
}

@end
