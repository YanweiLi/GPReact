//
//  GPRPathTrampoline.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRPathTrampoline.h"
#import "GPRMutableNode.h"
#import "GPRNode+Operation.h"
#import "GPRNode+Listen.h"
#import "GPRMarcoDefine.h"
#import "GPRListenContext.h"
#import "GPRCancelableBag.h"
#import "NSObject+GPRExt.h"

#import <GPFoundation/GPFoundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

static void swizzleDeallocIfNeeded(Class classToSwizzle);

@implementation GPRPathTrampoline
{
    __unsafe_unretained NSObject *_target;
    NSMutableDictionary<NSString *, GPRMutableNode *> *_keyPathNodes;
    NSMutableDictionary<NSString *, NSNumber *> *_syncFlags;
    
    GPS_LOCK_DEF(_keyPathNodesLock);
    GPS_LOCK_DEF(_syncFlagsLock);
    
    GPRCancelableBag *_cancelBag;
}

- (instancetype) initWithTarget:(id)target
{
    if (self = [super init]) {
        _target = target;
        
        _keyPathNodes = [NSMutableDictionary dictionary];
        _syncFlags = [NSMutableDictionary dictionary];
        
        GPS_LOCK_INIT(_keyPathNodesLock);
        GPS_LOCK_INIT(_syncFlagsLock);
        
        _cancelBag = [GPRCancelableBag bag];
        swizzleDeallocIfNeeded([_target class]);
    }
    return self;
}

- (void) removeAllObservers
{
    NSArray<NSString *> *keyPaths = ({
        GPS_SCOPE_LOCK(self->_keyPathNodesLock);
        self->_keyPathNodes.allKeys;
    });
    
    for (NSString *keyPath in keyPaths) {
        [self->_target removeObserver:self forKeyPath:keyPath];
    }
}

- (void) setObject:(GPRNode *)node forKeyedSubscript:(NSString *)keyPath
{
    NSParameterAssert(node);
    NSParameterAssert(keyPath);
    
    GPRMutableNode *keyPathNode = self[keyPath];
    [_cancelBag addCancelable:[keyPathNode syncWith:node]];
}

- (GPRMutableNode *) nodeWithKeyPath:(NSString *)keyPath
{
    GPS_SCOPE_LOCK(_keyPathNodesLock);
    return _keyPathNodes[keyPath];
}

- (void) setKeyPath:(NSString *)keyPath node:(GPRMutableNode *)node
{
    GPS_SCOPE_LOCK(_keyPathNodesLock);
    GPS_SCOPE_LOCK(_syncFlagsLock);
    _keyPathNodes[keyPath] = node;
    _syncFlags[keyPath] = @YES;
}

- (BOOL) needSyncWithKeyPath:(NSString *)keyPath
{
    GPS_SCOPE_LOCK(_syncFlagsLock);
    return [_syncFlags[keyPath] boolValue];
}

- (void) setKeyPath:(NSString *)keyPath needSync:(BOOL)state
{
    GPS_SCOPE_LOCK(_syncFlagsLock);
    _syncFlags[keyPath] = @(state);
}

- (GPRMutableNode *) objectForKeyedSubscript:(NSString *)keyPath
{
    NSParameterAssert(keyPath);
    GPRMutableNode *keyPathNode = [self nodeWithKeyPath:keyPath];
    
    if (!keyPathNode) {
        keyPathNode = GPRMutableNode.new;
        
        [self setKeyPath:keyPath node:keyPathNode];
        
        @GPRWeakify(self)
        [[keyPathNode listenedBy:self] withBlock:^(id  _Nullable next) {
            @GPRStrongify(self)
            if (!self) { return ; }
            
            if ([self needSyncWithKeyPath:keyPath]) {
                [self setKeyPath:keyPath needSync:NO];
                [self->_target setValue:next forKeyPath:keyPath];
            } else {
                [self setKeyPath:keyPath needSync:YES];
            }
        }];
        
        [_target addObserver:self
                  forKeyPath:keyPath
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                     context:NULL];
    }
    
    return keyPathNode;
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                        context:(void *)context
{
    GPRMutableNode *keyPathNode = [self nodeWithKeyPath:keyPath];
    
    id valueForPath = change[NSKeyValueChangeNewKey];
    if ([valueForPath isKindOfClass:NSNull.class]) {
        valueForPath = nil;
    }
    
    if ([self needSyncWithKeyPath:keyPath]) {
        [self setKeyPath:keyPath needSync:NO];
        keyPathNode.value = valueForPath;
    } else {
        [self setKeyPath:keyPath needSync:YES];
    }
}

@end

///////////////////////////////////////////////////////////////////////////

static NSMutableSet *swizzledClasses()
{
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    
    return swizzledClasses;
}

static void swizzleDeallocIfNeeded(Class classToSwizzle)
{
    @synchronized (swizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([swizzledClasses() containsObject:className]) return;
        
        SEL deallocSelector = sel_registerName("dealloc");
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        id newDealloc = ^(__unsafe_unretained id self) {
            [[self gpr_path] removeAllObservers];
            
            if (originalDealloc == NULL) {
                struct objc_super superInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(classToSwizzle)
                };
                
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            // The class already contains a method implementation.
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            
            // We need to store original implementation before setting new implementation
            // in case method is called at the time of setting.
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            
            // We need to store original implementation again, in case it just changed.
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        
        [swizzledClasses() addObject:className];
    }
}
