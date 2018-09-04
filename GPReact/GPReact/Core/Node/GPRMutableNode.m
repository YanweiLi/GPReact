//
//  GPRMutableNode.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRMutableNode.h"
#import "GPRMarcoDefine.h"

// base
#import "GPREmpty.h"
#import "GPRTransform.h"
#import "GPRBlockCancelable.h"

// protocol
#import "GPRListenEdge.h"
#import "GPRTransformEdge.h"
#import "GPRNextReceiver.h"

// utility
#import "GPRSenderList.h"
#import "GPRMarcoDefine.h"

// private
#import "GPRNode+Private.h"
#import "GPRMutableNode+Private.h"
#import "GPRListenContext+Private.h"

#import <objc/runtime.h>

NSString *GPRExceptionReason_CannotModifyGPRNode = @"GPRExceptionReason_CannotModifyGPRNode";
static inline GPSFliterBlock gpr_is_property_exist(NSString *keyPath)
{
    return ^BOOL (id item) {
        id property = [item valueForKeyPath:keyPath];
        return !!property;
    };
}

@interface GPRMutableNode () <GPRNextReceiver>
@end

@implementation GPRMutableNode

@synthesize value = _value, name = _name, mutable = _mutable;

#pragma mark initializer

- (instancetype) initDirectly
{
    if (self = [self init]) {
    }
    return self;
}

- (instancetype) init
{
    if (self = [self initWithValue:[GPREmpty empty] mutable:YES]) {
    }
    return self;
}

- (instancetype) initWithValue:(id)value
{
    if (self = [self initWithValue:value mutable:YES]) {
    }
    return self;
}

- (instancetype) initWithValue:(id)value mutable:(BOOL)isMutable
{
    if (self = [super initDirectly]) {
        _value = value;
        _mutable = isMutable;
        _privateListenEdges = @[];
        _privateUpstreamTransforms = @[];
        _privateDownstreamTransforms = @[];
        GPS_LOCK_INIT(_valueLock);
        GPS_LOCK_INIT(_upstreamLock);
        GPS_LOCK_INIT(_downstreamLock);
        GPS_LOCK_INIT(_listenEdgeLock);
    }
    return self;
}

- (instancetype) named:(NSString *)name
{
    return [self namedWithFormat:name];
}

- (instancetype) namedWithFormat:(NSString *)format, ...
{
    NSCParameterAssert(format != nil);
    
    va_list args;
    va_start(args, format);
    
    NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    _name = str;
    return self;
}

+ (instancetype) value:(id)value
{
    return [[GPRMutableNode alloc] initWithValue:value];
}

- (void) setValue:(id)value
{
    [self setValue:value context:nil];
}

- (void) setValue:(id)value context:(nullable id)context
{
    if GPR_LikelyNO(!self.isMutable) {
        GPR_THROW(GPRNodeExceptionName, GPRExceptionReason_CannotModifyGPRNode, nil);
    }
    
    [self next:value from:[GPRSenderList new] context:context];
}

- (void) clean
{
    self.value = [GPREmpty empty];
}

#pragma mark value's setter and getter

- (void) next:(nullable id)value from:(GPRSenderList *)senderList context:(nullable id)context
{
    {
        GPS_SCOPE_LOCK(_valueLock);
        _value = value;
    }
    
    if GPR_LikelyNO(value == GPREmpty.empty) {
        return;
    }
    
    GPRSenderList *newQueue = [senderList appendNewSender:self];
    
    for (GPSWeakReference<id<GPRListenEdge>> *item in self.privateListenEdges) {
        [item.reference next:value from:newQueue context:context];
    }
    
    for (GPSWeakReference<id<GPRTransformEdge>> *reference in self.privateDownstreamTransforms) {
        id<GPRTransformEdge> item = reference.reference;
        if GPR_LikelyYES(![senderList contains:item.to]) {
            [item next:value from:newQueue context:context];
        }
    }
}

- (id) value
{
    GPS_SCOPE_LOCK(_valueLock);
    return _value;
}

- (BOOL) isEmpty
{
    return self.value == GPREmpty.empty;
}

#pragma mark listener

- (NSArray<id<GPRListenEdge>> *) listenEdges
{
    return [[GP_NEW_SEQ(self.privateListenEdges) map:gps_valueForKeypath(@"reference")] as:NSArray.class];
}

- (BOOL) hasListener
{
    return [GP_NEW_SEQ(self.privateListenEdges) any:gpr_is_property_exist(@"reference.to")];
}

- (void) addListenEdge:(id<GPRListenEdge>)listenEdge
{
    NSParameterAssert(listenEdge);
    if GPR_LikelyNO(!listenEdge) {
        return ;
    }
    
    for (GPSWeakReference<id<GPRListenEdge>> * _Nonnull item in self.privateListenEdges) {
        if GPR_LikelyNO(item.reference == listenEdge) {
            return;
        }
    }
    
    GPS_SCOPE_LOCK(_listenEdgeLock);
    self.privateListenEdges = [self.privateListenEdges arrayByAddingObject:[GPSWeakReference reference:listenEdge]];
}

- (void) removeListenEdge:(id<GPRListenEdge>)listenEdge
{
    NSParameterAssert(listenEdge);
    GPS_SCOPE_LOCK(_listenEdgeLock);
    NSUInteger removeIndex = 0;
    for (GPSWeakReference<id<GPRListenEdge>> *reference in self.privateListenEdges) {
        if (reference.reference == listenEdge) {
            NSMutableArray *listenEdges = [self.privateListenEdges mutableCopy];
            [listenEdges removeObjectAtIndex:removeIndex];
            self.privateListenEdges = listenEdges;
            return;
        }
        
        ++removeIndex;
    }
}

#pragma mark downstream

- (NSArray<GPRNode *> *) downstreamNodes
{
    return [[[GP_NEW_SEQ(self.privateDownstreamTransforms)
              select:gpr_is_property_exist(@"reference.to")]
             map:gps_valueForKeypath(@"reference.to")]
            as:NSArray.class];
}

- (NSArray<id<GPRTransformEdge>> *) downstreamTransforms
{
    return [[GP_NEW_SEQ(self.privateDownstreamTransforms) map:gps_valueForKeypath(@"reference")] as:NSArray.class];
}

- (BOOL) hasDownstreamNode
{
    return [GP_NEW_SEQ(self.privateDownstreamTransforms) any:gpr_is_property_exist(@"reference.to")];
}

- (id<GPRCancelable>) linkTo:(GPRMutableNode *)node
                   transform:(id<GPRTransformEdge>)transform
{
    if (!node || node == self) {
        return nil;
    }
    
    NSParameterAssert(transform);
    if (!transform) {
        return nil;
    }
    
    NSAssert(transform.from == nil && transform.to == nil , @"this transform already used ");
    if (transform.from != nil && transform.to != nil) {
        return nil;
    }
    
    transform.from = node;
    transform.to = self;
    @GPRWeakify(transform);
    return [[GPRBlockCancelable alloc] initWithBlock:^{
        @GPRStrongify(transform);
        transform.from = nil;
        transform.to = nil;
    }];
}

- (id<GPRCancelable>) linkTo:(GPRNode *)node
{
    return [self linkTo:node transform:GPRTransform.new];
}

- (void) removeDownstreamNode:(GPRNode *)downstream
{
    NSParameterAssert(downstream);
    [GP_NEW_SEQ([self downstreamTransformsToNode:downstream]) forEach:^(id<GPRTransformEdge>  _Nonnull value) {
        value.from = nil;
        value.to = nil;
    }];
}

- (NSArray<id<GPRTransformEdge>> *) upstreamTransformsFromNode:(GPRNode *)from
{
    return [[GP_NEW_SEQ(self.privateUpstreamTransforms) select:^BOOL(id<GPRTransformEdge>  _Nonnull value) {
        return value.from == from;
    }] as:NSArray.class];
}

- (NSArray<id<GPRTransformEdge>> *) downstreamTransformsToNode:(GPRNode *)to
{
    return [[[GP_NEW_SEQ(self.privateDownstreamTransforms) select:^BOOL(GPSWeakReference<id<GPRTransformEdge>> * _Nonnull value) {
        return value.reference.to == to;
    }] map:gps_valueForKeypath(@"reference")]
            as:NSArray.class];
}

- (void) removeTransform:(id<GPRTransformEdge>)transform
{
    NSParameterAssert(transform);
    transform.from = nil;
    transform.to = nil;
}

- (void) removeDownstreamNodes
{
    [GP_NEW_SEQ(self.privateDownstreamTransforms) forEach:^(GPSWeakReference<id<GPRTransformEdge>> * _Nonnull value) {
        [self removeTransform:value.reference];
    }];
}

- (void) removeUpstreamNode:(GPRNode *)upstream
{
    NSParameterAssert(upstream);
    [upstream removeDownstreamNode:self];
}

- (void) removeUpstreamNodes
{
    [GP_NEW_SEQ(self.privateUpstreamTransforms) forEach:^(id<GPRTransformEdge>  _Nonnull value) {
        [self removeTransform:value];
    }];
}

#pragma mark upstream

- (NSArray<GPRNode *> *) upstreamNodes
{
    return [[[GP_NEW_SEQ(self.privateUpstreamTransforms) select:gpr_is_property_exist(gps_KeyPath(GPRTransform, from))]
             map:gps_valueForKeypath(gps_KeyPath(GPRTransform, from))]
            as:NSArray.class];
}

- (NSArray<id<GPRTransformEdge>> *) upstreamTransforms
{
    return self.privateUpstreamTransforms;
}

- (BOOL) hasUpstreamNode
{
    return [GP_NEW_SEQ(self.privateUpstreamTransforms) any:gpr_is_property_exist(gps_KeyPath(GPRTransform, from))];
}

#pragma mark - operator data structure

- (id<GPRNextReceiver>) addUpstreamTransformData:(id<GPRTransformEdge>)transform
{
    NSParameterAssert(transform);
    if (!transform) {
        return nil;
    }
    
    BOOL exists = [GP_NEW_SEQ(self.privateUpstreamTransforms) any:^BOOL(id<GPRTransformEdge> _Nonnull item) {
        return item == transform;
    }];
    
    if (!exists) {
        GPS_SCOPE_LOCK(_upstreamLock);
        self.privateUpstreamTransforms = [self.privateUpstreamTransforms arrayByAddingObject:transform];
    }
    
    return self;
}

- (void) addDownstreamTransformData:(id<GPRTransformEdge>)transform
{
    NSParameterAssert(transform);
    if (!transform) {
        return ;
    }
    
    BOOL exists = [GP_NEW_SEQ(self.privateDownstreamTransforms) any:^BOOL(GPSWeakReference<id<GPRTransformEdge>> * _Nonnull item) {
        return item.reference == transform;
    }];
    
    if (!exists) {
        GPS_SCOPE_LOCK(_downstreamLock);
        self.privateDownstreamTransforms = [self.privateDownstreamTransforms arrayByAddingObject:[GPSWeakReference reference:transform]];
    }
}

- (void) removeUpstreamTransformData:(id<GPRTransformEdge>)transform
{
    NSParameterAssert(transform);
    GPS_SCOPE_LOCK(_upstreamLock);
    NSMutableArray *upstreamTransforms = [self.privateUpstreamTransforms mutableCopy];
    [upstreamTransforms removeObject:transform];
    self.privateUpstreamTransforms = upstreamTransforms;
}

- (void) removeDownstreamTransformData:(id<GPRTransformEdge>)transform
{
    NSParameterAssert(transform);
    GPS_SCOPE_LOCK(_downstreamLock);
    
    NSUInteger removeIndex = 0;
    for (GPSWeakReference<id<GPRTransformEdge>> *reference in self.privateDownstreamTransforms) {
        if (reference.reference == transform) {
            NSMutableArray *downstreamTransforms = [self.privateDownstreamTransforms mutableCopy];
            [downstreamTransforms removeObjectAtIndex:removeIndex];
            self.privateDownstreamTransforms = downstreamTransforms;
            return;
        }
        
        ++removeIndex;
    }
}

#pragma mark others

- (NSString *) description
{
    return [NSString stringWithFormat:@"GPRNode(named:%@ value:%@)", self.name ?: @"undefined", self.value];
}

@end
