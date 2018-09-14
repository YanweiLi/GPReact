//
//  GPRNode+Operation.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"
#import <GPFoundation/GPFoundation.h>
#import "GPRMarcoDefine.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const GPRExceptionReason_SyncTransformBlockAndRevertNotInverseOperations;
FOUNDATION_EXTERN NSString * const GPRExceptionReason_FlattenOrFlattenMapNextValueNotGPRNode;
FOUNDATION_EXTERN NSString * const GPRExceptionReason_MapEachNextValueNotTuple;
FOUNDATION_EXTERN NSString * const GPRExceptionReason_CasedNodeMustGenerateBySwitchOrSwitchMapOperation;

@interface GPRNode <T:id> (Operation)

#pragma mark - For single upstream

/**
 This operation is a copy action.
 Fork operation will return a new node as the receiver's downstream.
 
 @return    New node, whose value keeping same as the receiver
 */
- (GPRNode<T> *)fork;

/**
 Map operation will return a new node as the receiver's downstream. The block will be called each time the receiver changes, and a new value will be assigned to the returned node after executing the block and processing the changing value of the receiver.
 
 @param block   Processing block of map operation
 @return        New node, whose value is the return value of the block
 */
- (GPRNode *)map:(id _Nullable (^)(T _Nullable next))block;

/**
 Filters operation will return a new node as the receiver's downstream. The block will be called each time the receiver changes, processing the changing value of the receiver and returning a BOOL value deciding whether new node will receive this value. If this value is received, it will be the value of the new node.
 
 @param block   Processing block of filter operation
 @return        New node, whose value will equal to receiver's value if block returns YES. Otherwise, value won't change.
 */
- (GPRNode<T> *)filter:(BOOL (^)(T _Nullable next))block;

/**
 Skips the first N times value. Skip operation will return a new node as the receiver's downstream.
 
 @param number  The number of values needed to be skipped(ignored)
 @return        New node, whose value will be same as the receiver's value after the first 'number' times changes of the receiver
 */
- (GPRNode<T> *)skip:(NSUInteger)number;

/**
 Takes the first N times value. Take operation will return a new node as the receiver's downstream.
 
 @param number  The number of values needed to be taken
 @return        New node, whose value will be same as the receiver's value within the first 'number' times changes of the receiver
 */
- (GPRNode<T> *)take:(NSUInteger)number;

/**
 Ignores the specific value. Ignore operation will return a new node as the receiver's downstream.
 
 @param ignoreValue     Value needed to be ignored
 @return                New node, whose value will keep unchanged if the receiver's value equals to 'ignoreValue', otherwise the value of new node will keep same with the receiver's value
 */
- (GPRNode<T> *)ignore:(nullable T)ignoreValue;

/**
 Selects the specific value. Select operation will return a new node as the receiver's downstream.
 
 @param selectedValue   The value needed to be selected
 @return                New node, whose value will keep the same with the receiver's value if the receiver's value equals to 'selectedValue', otherwise, the value of new node will keep unchanged.
 */
- (GPRNode<T> *)select:(nullable T)selectedValue;

/**
 Uses the specific value instead of the value passing from the receiver. MapReplace operation will return a new node as the receiver's downstream.
 
 @param mappedValue     The value used to replace the value passing from the receiver.
 @return                New node, whose value will be 'mappedValue' when the receiver's value changes.
 */
- (GPRNode *)mapReplace:(nullable id)mappedValue;

/**
 Only receives value that not repeated continuously. DistinctUntilChanged operation will return a new node as the receiver's downstream.
 
 @return        New node, whose value will only change when the value passing from the receiver is diffrent from current value.
 */
- (GPRNode<T> *)distinctUntilChanged;

/**
 This operation is used to process the node itself.
 
 @param thenBlock   Processing block, the parameter 'node' is the caller itself.
 @return            The receiver
 */
- (GPRNode<T> *)then:(void(NS_NOESCAPE^)(GPRNode<T> *node))thenBlock;

/**
 This operation is used to transmit value through the specific queue. DeliverOn operation will return a new node as the receiver's downstream.
 
 @param queue       The specific queue, using to transmit value
 @return            New value, whose value keeps the same with the receiver's value
 */
- (GPRNode<T> *)deliverOn:(dispatch_queue_t)queue;

/**
 This operation is used to transmit value through the main queue. DeliverOnMainQueue operation will return a new node as the receiver's downstream.
 
 @return            New value, whose value keeps the same with the receiver's value
 */
- (GPRNode<T> *)deliverOnMainQueue;

/**
 Synchronizes the current value with another value.
 The other GPRNode's value will be set to the current GPRNode's value even if the current value is empty.
 
 @note Both current GPRNode and othGPRNode must response to -(void)setValue: method, otherwise you will receive an exception while syncing.
 
 @param othGPRNode  The other GPRNode you want to sync.
 @return            A cancelable object which is able to stop syncing.
 */
- (id<GPRCancelable>)syncWith:(GPRNode<T> *)othGPRNode;

/**
 Sync the current value to another value.
 The other GPRNode's value will be set to the current GPRNode's value even if the current value is empty.
 
 @param othGPRNode  The other GPRNode you want to sync.
 @param transform   Current nodes's value will use transform to other node.
 @param revert      The other node's value will use revert to current node.
 @return            A cancelable object which is able to stop syncing.
 */
- (id<GPRCancelable>)syncWith:(GPRNode *)othGPRNode transform:(id (^)(T source))transform revert:(T (^)(id target))revert;

/**
 The operation used to reduce order after mapping node. FlattenMap operation will return a new node as the receiver's downstream. The value of the receiver will transfer to a node after block execution, and then be reduced order.
 
 @param block   Processing block of map, receiving a value and returning a node for reducing order.
 @return        New node, whose value is the returned node's value of mapping block
 */
- (GPRNode *)flattenMap:(GPRNode * _Nullable (^)(T _Nullable next))block;

/**
 The operation used to reduce order of node. Flatten operation will return a new node as the receiver's downstream. When the receiver's value is a GPRNode, the value of new node will change, and will equal to the value of the receiver's value.
 
 @return        New node
 */
- (GPRNode *)flatten;

/**
 Changes value if and only if the value does not change again in `interval` seconds.
 
 @discusstion If a value does not last for `interval` seconds, its listeners / downstreamNodes will not receive this value.
 An throttled empty value will not notify its listeners or downdstreams no matter how long it remains empty.
 The listener or downstream blocks will always be invoked in the main queue.
 If you want to dispatch those blocks to a specified queue, use `-throttle:queue:` method.
 
 @note It is NOT a real time mechanism, just like an NSTimer.
 
 @param timeInterval    The time interval in seconds, MUST be greater than 0.
 @return                A new GPRNode which change its value if and only if the value lasts for a given interval.
 */
- (GPRNode<T> *)throttleOnMainQueue:(NSTimeInterval)timeInterval;

/**
 Changes value if and only if the value does not change again in `interval` seconds.
 
 @discusstion If a value does not last for `interval` seconds, its listeners / downstreamNodes will not receive this value.
 An throttled empty value will not notify its listeners or downdstreams no matter how long it remains empty.
 
 @note It is NOT a real time mechanism, just like an NSTimer.
 
 @param timeInterval    The time interval in seconds, MUST be greater than 0.
 @param queue           The queue which listener block will be invoked in.
 @return                A new GPRNode which change its value if and only if the value lasts for a given interval.
 */
- (GPRNode<T> *)throttle:(NSTimeInterval)timeInterval queue:(dispatch_queue_t)queue;

/**
 Delays the passing value from the receiver in specific queue. Delay operation will return a new node as the receiver's downstream.
 
 @param timeInterval    Delayed time interval, in second
 @param queue           The specific queue for passing value
 @return                New node, whose value equals to the receiver's value.
 */
- (GPRNode<T> *)delay:(NSTimeInterval)timeInterval queue:(dispatch_queue_t)queue;

/**
 Delays the passing value from the receiver in the main queue. Delay operation will return a new node as the receiver's downstream.
 
 @param timeInterval    Delayed time interval, in second
 @return                New node, whose value equals to the receiver's value.
 */
- (GPRNode<T> *)delayOnMainQueue:(NSTimeInterval)timeInterval;

/**
 Reduces the changing value of node each time. Scan operation will return a new node as the receiver's downstream. Each time the node changes, 'reduceBlock' will be called and will return a running value for passing to the 'reduceBlock' again at next change.
 
 @param startingValue   Beginning Value
 @param reduceBlock     Block for reducing, with parameters:
 <pre>@textblock
 running     - Reducing result last time
 next        - Current value of node
 @/textblock</pre>
 @return                New node, whose value is running value.
 */
- (GPRNode *)scanWithStart:(nullable id)startingValue reduce:(id (^)(id _Nullable running, T _Nullable next))reduceBlock;

/**
 Reduces the changing value of node each time. Scan operation will return a new node as the receiver's downstream. Each time the node changes, 'reduceBlock' will be called and will return a running value for passing to the 'reduceBlock' again  at next change.
 
 @param startingValue   Beginning Value
 @param reduceBlock     Block for reducing, with parameters:
 <pre>@textblock
 running     - Reducing result last time
 next        - Current value of node
 index       - index of the value changes, starts from 0.
 @/textblock</pre>
 @return                New node, whose value is running value.
 */
- (GPRNode *)scanWithStart:(nullable id)startingValue reduceWithIndex:(id (^)(id _Nullable running, T _Nullable next, NSUInteger index))reduceBlock;

#pragma mark For multipart upstreamNodes

/**
 Combines mutiple nodes into one node, for the convenience of processing mutiple nodes in one time. Combine operation will return a new node as the muliple nodes' downstream. The new node value will change when none of the muliple nodes' values is GPREmpty.
 
 @param nodes       Nodes that will be combined
 @return            New node, which is kind of GPTupleBase, is a tuple consitituted by muliple nodes.
 */
+ (GPRNode<__kindof GPTupleBase *> *)combine:(NSArray<GPRNode *> *)nodes;

/**
 Combines the receiver and the passing node together, same as [GPRNode combine:@[self, node]]
 
 @param node        Node that will be combined
 @return            New node, which is kind of GPTupleBase, is a tuple consitituted by the receiver and passing node.
 */
- (GPRNode<GPTuple2<T, id> *> *)combine:(GPRNode *)node;

/**
 Merges mutiple nodes into one node, for the convenience of processing mutiple nodes in one time. Merge operation will return a new node as mutiple nodes' downstream. If any of those nodes changes, the value of new node will change.
 
 @param nodes       Node that will be merged
 @return            New node
 */
+ (GPRNode *)merge:(NSArray<GPRNode *> *)nodes;

/**
 Merges the current node and the passing node together, same as [GPRNode merge:@[self, node]]
 
 @param node        Node that will be merged
 @return            New node
 */
- (GPRNode *)merge:(GPRNode *)node;

/**
 Zips several GPRNodes into one.
 
 @discussion The value of the zipped value is an GPRNode which contains an array of values.
 The content of the array is the k-th (k >= 1) value of all the sources.
 If any value in the sources is empty, the initial value of the zipped value will be empty as well.
 Any nil value from the sources will be converted to NSNull.null since an array MUST NOT contain a nil.
 The array will change its content if and only if all the sources have recieved at least one new value.
 You can add / remove upstreamNodes after creating the zipped value.
 The zipped value will be re-calculated after adding / removing an upstream.
 
 @param nodes       An array of source GPRNodes. It should NOT be empty.
 @return            An GPRNode contains an array of zipped values.
 */
+ (GPRNode<__kindof GPTupleBase *> *)zip:(NSArray<GPRNode *> *)nodes;

/**
 Zips current node with the passing node together, same as [GPRNode zip:@[self, node]]
 
 @param node        GPRNode that will be zipped with current node
 @return            New GPRNode
 */
- (GPRNode<GPTuple2<T, id> *> *)zip:(GPRNode *)node;

@end

////////////////////////////////////////////////////////////////////////////////////////////

#define GPRCombine(...)  _GPRCombine(__VA_ARGS__)
#define GPRZip(...) _GPRZip(__VA_ARGS__)

GPR_MapEachFakeInterfaceDef(15)

#define GPRIFResultTable(_) \
_(GPRNode<T> *, thenNode) \
_(GPRNode<T> *, elseNode);

_GPTNamedTupleDef(GPRIFResult, T)

#define GPRSwitchedNodeTupleTable(_) \
_(id<NSCopying>, key) \
_(GPRNode<T> *, node);

_GPTNamedTupleDef(GPRSwitchedNodeTuple, T)

@interface GPRIFResult<T> (Extension)

- (GPRIFResult<T> *)then:(void (NS_NOESCAPE ^)(GPRNode<T> *node))thenBlock;
- (GPRIFResult<T> *)else:(void (NS_NOESCAPE ^)(GPRNode<T> *node))elseBlock;

@end

//////////////////////////////////////////////////////////////////////////////////////////

@interface GPRNode<T: id> (SwitchCase)

/**
 Using the return key of 'switchBlock' to group the future values of current node. If there is no corresponding downstream node for current key, a new node will be created. it is usually used to separate various return nodes, and we can get the specific key value node through 'if', 'case', 'default' operation afterwards.
 
 @param switchBlock         Block used for grouping
 @return                    GPRNode whose value is kind of GPRSwitchedNodeTuple
 */
- (GPRNode<GPRSwitchedNodeTuple<T> *> *)switch:(id<NSCopying> _Nullable (^)(T _Nullable next))switchBlock;


/**
 Using the return key of 'switchBlock' to group the future values of current node. If there is no corresponding downstream node for current key, a new node will be created. it is usually used to separate various return nodes, and wen can get the specific key value node through 'if', 'case', 'default' operation afterwards.
 
 @param switchMapBlock      Block used for grouping
 @return                    GPRNode whose value is kind of GPRSwitchedNodeTuple
 */
- (GPRNode<GPRSwitchedNodeTuple<id> *> *)switchMap:(GPTuple2<id<NSCopying>, id> *(^)(T _Nullable next))switchMapBlock;

/**
 Filters the node created by - [GPRNode switch:] or - [GPRNode switchMap:] into the one that corresponds to specific key.
 
 @param key         Specific key
 @return            Node whose value corresponds to specific key.
 */
- (GPRNode *)case:(nullable id<NSCopying>)key;

/**
 Separates current node into node that satisfies condition and node not satisfies. like [[GPRNode switch:] case:@YES] and [[GPRNode switch:] case:@NO]
 
 @param block       Judge rules for separating node
 @return            Tuple of node after separation
 */
- (GPRIFResult<T> *)if:(BOOL (^)(T _Nullable next))block;

/**
 Operation that matches nil. nil could be also used as key
 
 @return            Node using nil as key
 */
- (GPRNode *)default;

@end
NS_ASSUME_NONNULL_END
