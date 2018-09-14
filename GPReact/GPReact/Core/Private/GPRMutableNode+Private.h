//
//  GPRMutableNode+Private.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRMutableNode.h"
#import "GPRMarcoDefine.h"

NS_ASSUME_NONNULL_BEGIN
@protocol GPRListenEdge;

@interface GPRMutableNode ()
{
@private
    id _value;
    GPS_LOCK_DEF(_valueLock);
    GPS_LOCK_DEF(_upstreamLock);
    GPS_LOCK_DEF(_downstreamLock);
    GPS_LOCK_DEF(_listenEdgeLock);
}

@property (atomic, assign, getter=isMutable) BOOL mutable;
@property (atomic, copy) NSArray<id<GPRTransformEdge>> *privateUpstreamTransforms;
@property (atomic, copy) NSArray<GPSWeakReference<id<GPRTransformEdge>> *> *privateDownstreamTransforms;
@property (atomic, copy) NSArray<GPSWeakReference<id<GPRListenEdge>> *> *privateListenEdges;

@end

NS_ASSUME_NONNULL_END
