//
//  GPRNode+Traversal.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode+Traversal.h"
#import "GPRTransformEdge.h"
#import <GPFoundation/GPFoundation.h>

@interface GPRNodeVisitElement : NSObject
@property (nonatomic, strong) GPRNode *node;
@property (nonatomic, assign) NSInteger deep;
- (BOOL)accept:(id<GPRNodeVisitor>)visitor;
@end

@implementation GPRNodeVisitElement

- (BOOL) isEqual:(GPRNodeVisitElement *)object
{
    if ([object isKindOfClass:[GPRNodeVisitElement class]]) {
        return [self.node isEqual:object.node];
    }
    
    return NO;
}

- (NSUInteger) hash
{
    return self.node.hash;
}

- (BOOL) accept:(id<GPRNodeVisitor>)visitor
{
    if ([visitor respondsToSelector:@selector(visitNode:deep:)]) {
        return [visitor visitNode:self.node deep:self.deep];
    }
    
    return NO;
}

@end

//////////////////////////////////////////////////////////////////////

@interface GPRNode (VisitElement)
- (GPRNodeVisitElement *)gpr_visitElementWithDeep:(NSInteger)deep;
@end

@implementation GPRNode (VisitElement)

- (GPRNodeVisitElement *) gpr_visitElementWithDeep:(NSInteger)deep
{
    GPRNodeVisitElement *element = [GPRNodeVisitElement new];
    element.node = self;
    element.deep = deep;
    return element;
}

@end

@implementation GPRNode (Traversal)

- (void) traversal:(id<GPRNodeVisitor>)visitor
{
    NSMutableSet<GPRNodeVisitElement *> *uniqueElementSet = [NSMutableSet new];
    NSMutableSet<id<GPRTransformEdge>> *uniqueTransformSet = [NSMutableSet new];
    GPSQueue<GPRNodeVisitElement *> *traversalQueue = [GPSQueue new];
    
    GPRNodeVisitElement *root = [self gpr_visitElementWithDeep:0];
    [uniqueElementSet addObject:root];
    [traversalQueue enqueue:root];
    
    typedef void (^ForEachType)(GPRNode *value);
    ForEachType (^enqueNewElement)(NSInteger deep) = ^ForEachType(NSInteger deep) {
        return ^void(GPRNode *node) {
            GPRNodeVisitElement *subElement = [node gpr_visitElementWithDeep:deep];
            if (![uniqueElementSet containsObject:subElement]) {
                [uniqueElementSet addObject:subElement];
                [traversalQueue enqueue:subElement];
            }
        };
    };
    
    while (![traversalQueue isEmpty]) {
        GPRNodeVisitElement *element = [traversalQueue dequeue];
        if ([element accept:visitor]) {
            return ;
        }
        
        [GP_NEW_SEQ(element.node.upstreamNodes) forEach:enqueNewElement(element.deep - 1)];
        [GP_NEW_SEQ(element.node.downstreamNodes) forEach:enqueNewElement(element.deep + 1)];
        if ([visitor respondsToSelector:@selector(visitTransform:)]) {
            [GP_NEW_SEQ([element.node.upstreamTransforms arrayByAddingObjectsFromArray:element.node.downstreamTransforms]) forEach:^(id<GPRTransformEdge> _Nonnull value) {
                if (![uniqueTransformSet containsObject:value]) {
                    [uniqueTransformSet addObject:value];
                    if ([visitor visitTransform:value]) {
                        return ;
                    }
                }
            }];
        }
    }
}

@end
