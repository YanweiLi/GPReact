//
//  GPRTransformEdge.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPREdge.h"
#import "GPRNextReceiver.h"
@class GPRNode;

@protocol GPRTransformEdge <GPREdge, GPRNextReceiver>

/**
 The upstream value of the GPRTransformEdge
 */
@property (atomic, strong, nullable) GPRNode *from;

/**
 The downstream value of the GPRTransformEdge
 */
@property (atomic, weak, nullable) GPRNode *to;

/**
 Represent the next instance which can receive the value senderlist and context
 */
@property (atomic, weak, nullable) id<GPRNextReceiver> nextReceiver;
@end
