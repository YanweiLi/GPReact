//
//  GPRNode.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GPRCancelable, GPRTransformEdge;
@class GPRListenContext<T>;

@interface GPRNode <__covariant T:id> : NSObject

/**
 The name associated with the receiver, if any. Used for debugging or producing topological graph in convenience.
 */
@property (nonatomic, readwrite, strong, nullable) NSString *name;

/**
 A thread-safe object that defines the value of the receiver.
 */
@property (atomic, readonly, strong, nullable) T value;

/**
 A Boolean value that indicates whether the receiver is mutable.
 */
@property (atomic, readonly, assign, getter=isMutable) BOOL mutable;

/**
 An array of the receiver's upstream nodes.
 */
@property (atomic, readonly, copy) NSArray<GPRNode *> *upstreamNodes;

/**
 An array of the receiver's downstream nodes.
 */
@property (atomic, readonly, copy) NSArray<GPRNode *> *downstreamNodes;

/**
 An array of the receiver's upstream transformations.
 */
@property (atomic, readonly, copy) NSArray<id<GPRTransformEdge>> *upstreamTransforms;

/**
 An array of the receiver's downstream transformations.
 */
@property (atomic, readonly, copy) NSArray<id<GPRTransformEdge>> *downstreamTransforms;

/**
 A boolean value that indicates whether the receiver has upstream node.
 */
@property (atomic, readonly, assign) BOOL hasUpstreamNode;

/**
 A boolean value that indicates whether the receiver has downstream node.
 */
@property (atomic, readonly, assign) BOOL hasDownstreamNode;

/**
 A Boolean value that indicates whether the receiver has a listener.
 */
@property (atomic, readonly, assign) BOOL hasListener;

/**
 A Boolean value that indicates whether the node is equal to GPREmpty.empty
 The feature of empty is that GPREmpty.empty will not trigger listeners, nor change the downstream nodes.
 */
@property (atomic, readonly, assign, getter=isEmpty) BOOL empty;

/**
 Initializes a new node with GPREmpty.empty
 
 @return        New node instance
 */
- (instancetype)init;

/**
 Initializes a node with the given value
 
 @param value   Initial value
 @return        New node instance
 */
- (instancetype)initWithValue:(nullable T)value NS_DESIGNATED_INITIALIZER;

/**
 Returns a node with a given value
 
 @param value   Initial value
 @return        New node instance
 */
+ (instancetype)value:(nullable T)value;

/**
 Returns the receiver instance named by using a given name.
 
 @param name    Name
 @return        Node instance
 */
- (instancetype)named:(NSString *)name;

/**
 Returns the receiver instance named by using a given format string.
 
 @param format  Formatted string
 @param ...     Variadic parameter lists
 @return        Node instance
 */
- (instancetype)namedWithFormat:(NSString *)format, ...;

/**
 Links to a given upstream node using a specific transformation. The receiver will be the downstream node.
 
 @param node        Upstream node which wants to link to
 @param transform   Transforming action between upstream node
 @return            GPRCancelable object whose link can be cancelable
 */
- (id<GPRCancelable>)linkTo:(GPRNode *)node transform:(id<GPRTransformEdge>)transform;

/**
 Links to a given upstream node. The receiver will be the downstream node and will keep the same value with the given upstream node
 
 @param node    Upstream node which wants to link to
 @return        GPRCancelable object whose link can be cancelable
 */
- (id<GPRCancelable>)linkTo:(GPRNode *)node;

/**
 Finds the receiver's downstream transformations those linked to a given node. If not found, an empty array will be returned.
 
 @param to      Downstream node
 @return        Array of downstream edges
 */
- (NSArray<id<GPRTransformEdge>> *)downstreamTransformsToNode:(GPRNode *)to;

/**
 Finds the receiver's upstream transformations those linked to a given node. If not found, an empty array will be returned.
 
 @param from    Upstream node
 @return        Array of upstream edges
 */
- (NSArray<id<GPRTransformEdge>> *)upstreamTransformsFromNode:(GPRNode *)from;

/**
 Removes a specific downstream node, if any. The transformation connected to the specific downstream node will be removed also.
 
 @param downstream  The downstream node that will be removed
 */
- (void)removeDownstreamNode:(GPRNode *)downstream;

/**
 Removes all downstream nodes of the receiver
 */
- (void)removeDownstreamNodes;

/**
 Removes a specific upstream node, if any. The transformation connected to the specific upstream node will be removed also.
 
 @param upstream    The upstream node that will be removed
 */
- (void)removeUpstreamNode:(GPRNode *)upstream;

/**
 Removes all upstream nodes of the receiver
 */
- (void)removeUpstreamNodes;
@end

NS_ASSUME_NONNULL_END
