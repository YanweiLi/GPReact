//
//  GPRTransformEdge.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPRNode;

@protocol GPRTransformEdge <NSObject>

/**
 The upstream value of the EZRTransformEdge
 */
@property (atomic, strong, nullable) EZRNode *from;

/**
 The downstream value of the EZRTransformEdge
 */
@property (atomic, weak, nullable) EZRNode *to;

/**
 Represent the next instance which can receive the value senderlist and context
 */
@property (atomic, weak, nullable) id<EZRNextReceiver> nextReceiver;
@end
