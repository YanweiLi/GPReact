//
//  GPRMutableNode.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPRNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPRMutableNode <T> : GPRNode <T>

/**
 A thread-safe object that defines the value of the receiver.
 */
@property (atomic, readwrite, strong, nullable) T value;

/**
 Returns a new node created by a given boolean value to indicate whether the node is mutable.
 If being immutable, node will throw `GPRExceptionReason_CannotModifyGPRNode` exception when it is assigned value.
 
 @param value       Value of the node, could be nil
 @param isMutable   Whether current node is mutable or not
 @return            New node instance
 */
- (instancetype)initWithValue:(nullable T)value mutable:(BOOL)isMutable NS_DESIGNATED_INITIALIZER;

/**
 Sets value to node and attach a context if needed, the context will be transfer to downstream nodes and listeners.
 
 @param value       Value of the node
 @param context     Context
 */
- (void)setValue:(nullable T)value context:(nullable id)context;

/**
 Cleans the receiver's value to GPREmpty.empty.
 */
- (void)clean;
@end

NS_ASSUME_NONNULL_END
