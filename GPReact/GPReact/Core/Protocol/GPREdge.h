//
//  GPREdge.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GPREdge <NSObject>
@required

/**
 Name of the directed edge,
 used for data visualized debugging function
 */
@property (nonatomic, readwrite, copy, nullable) NSString *name;

/**
 Upstream node where the edge comes from,
 data transmission will happen when both upstream and downstream node have values
 */
@property (atomic, strong, nullable) id from;

/**
 Downstream node where the edge directs to,
 data transmission will happen when both upstream and downstream node have values
 */
@property (atomic, weak, nullable) id to;

@end
