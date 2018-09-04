//
//  GPRListenContext.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GPRCancelable , GPRListenEdge;
@class GPRSenderList;

NS_ASSUME_NONNULL_BEGIN

/**
 This class is an assistant class used for managing additional attached action
 when the values of notes were listened by listeners change.
 This class doesn't need users to manage the life cycle
 */
@interface GPRListenContext <T> : NSObject

/**
 Process in listening progress. Block will be called after the change of value.
 
 @param block   Block used to receive new value
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withBlock:(void (^)(T _Nullable next))block;


/**
 Process in listening progress. Block will be called after the change of value.
 
 @param block   Block used to receive new value, contains context besides new value
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withContextBlock:(void (^)(T _Nullable next, id _Nullable context))block;

/**
 Process in listening progress. Block will be called in the specific queue after the change of value.
 
 @param block   Block used to receive new value
 @param queue   The specific queue
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withBlock:(void (^)(T _Nullable next))block on:(dispatch_queue_t)queue;

/**
 Listens the change of value. The parameter block will be called in the specific queue when the value changes.
 
 @param block   Block used to receive new value, contains context besides new value
 @param queue   The specific queue
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withContextBlock:(void (^)(T _Nullable next, id _Nullable context))block on:(dispatch_queue_t)queue;

/**
 Listens the change of value. The parameter block will be called in the specific queue when the value changes.
 
 @param block   Block used to receive new value, contains context and senderlist besides new value
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withSenderListAndContextBlock:(void (^)(T _Nullable next, GPRSenderList *senderList,  id _Nullable context))block;

/**
 Listens the change of value. The parameter block will be called in the specific queue when the value changes.
 
 @param block   Block used to receive new value, contains context and senderlist besides new value
 @param queue   The specific queue
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withSenderListAndContextBlock:(void (^)(T _Nullable next, GPRSenderList *senderList,  id _Nullable context))block on:(dispatch_queue_t)queue;
/**
 Listens the change of value. The parameter block will be called in the main queue when the value changes.
 
 @param block   Block used to receive new value
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withBlockOnMainQueue:(void (^)(T _Nullable next))block;

/**
 Process in listening progress. Block will be called in the main queue after the change of value.
 
 @param block   Block used to receive new value, contains context besides new value
 @return        Object whose listen action can be cancelled
 */
- (id<GPRCancelable>) withContextBlockOnMainQueue:(void (^)(T _Nullable next, id _Nullable context))block;

/**
 Listens the change of value. The parameter's processing method will be called after the change of value.
 
 @param listenEdge  Listener used to receive new values, corresponding to GPRListenEdge protocol
 */
- (id<GPRCancelable>) withListenEdge:(id<GPRListenEdge>)listenEdge;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end
NS_ASSUME_NONNULL_END
