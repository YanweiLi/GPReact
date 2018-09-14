//
//  GPRNode+Traversal.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"
NS_ASSUME_NONNULL_BEGIN
/**
 Visitor protocol of GPRNode, used for traversing nodes and edges to get a topological graph.
 */
@protocol GPRNodeVisitor <NSObject>

@optional
/**
 Visits from a node by a given depth, and returns a boolean value to indicate whether the traversing finished.
 
 @param node    GPRNode
 @param deep    Depth, negative for upwards and positive for downwards
 @return        A boolean value to indicate whether the traversing finished.
 */
- (BOOL)visitNode:(GPRNode *)node deep:(NSInteger)deep;

/**
 Visits from a transformation by a given depth, and returns a boolean value to indicate whether the traversing finished.
 
 @param transform   Transforming edge
 @return            A boolean value to indicate whether the traversing finished.
 */
- (BOOL)visitTransform:(id<GPRTransformEdge>)transform;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface GPRNode (Traversal)

/**
 Begin traversing by a given visitor object.
 
 @param visitor     Visitor object
 */
- (void)traversal:(id<GPRNodeVisitor>)visitor;
@end
NS_ASSUME_NONNULL_END
