//
//  GPRListenEdge.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPRNextReceiver.h"
#import "GPREdge.h"

@class GPRNode;

@protocol GPRListenEdge <GPREdge, GPRNextReceiver>
/**
 The upstream value of the GPRNextReceiver
 */
@property (atomic, strong, nullable) GPRNode *from;
@end
