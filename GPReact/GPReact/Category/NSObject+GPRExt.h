//
//  NSObject+GPRExt.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GPRPathTrampoline;
@class GPRNode;
@class GPRMutableNode;

@interface NSObject (GPRExtension)

/**
 Object which implements subscript method,
 used for extending the KVO and KVC of the Foundation
 object's property and transforming into GPRNode
 */
@property (nonatomic, readonly, strong) GPRPathTrampoline *gpr_path;

/**
 Generates an immutable node object using current object
 
 @return    Immutable object whose initial value is current object
 */
- (GPRNode *) gpr_toNode;

/**
 Generates a mutable node object using current object
 
 @return    Mutable object whose initial value is current object
 */
- (GPRMutableNode *) gpr_toMutableNode;
@end

NS_ASSUME_NONNULL_END
