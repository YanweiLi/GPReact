//
//  GPRNode+Private.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"
NS_ASSUME_NONNULL_BEGIN

@class GPRSenderList;
@protocol GPRListenEdge, GPRNextReceiver , GPRTransformEdge;

// extension
@interface GPRNode ()
- (instancetype)initDirectly NS_DESIGNATED_INITIALIZER;
- (void)next:(nullable id)value from:(GPRSenderList *)senderList context:(nullable id)context;
@end

// category
@interface GPRNode<T> (Listener)
- (void)addListenEdge:(id<GPRListenEdge>)listenEdge;
- (void)removeListenEdge:(id<GPRListenEdge>)listenEdge;
@end

// category
@interface GPRNode (Transfrom)
- (id<GPRNextReceiver>)addUpstreamTransformData:(id<GPRTransformEdge>)transform;
- (void)addDownstreamTransformData:(id<GPRTransformEdge>)transform;
- (void)removeUpstreamTransformData:(id<GPRTransformEdge>)transform;
- (void)removeDownstreamTransformData:(id<GPRTransformEdge>)transform;
@end

NS_ASSUME_NONNULL_END
