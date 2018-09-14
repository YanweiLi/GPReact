//
//  GPRNode+Graph.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode+Graph.h"
#import "GPRTransformEdge.h"
#import "GPRNode+Traversal.h"
#import <GPFoundation/GPFoundation.h>

@interface GPRNode (DotLanguage)
- (NSString *)gpr_dotString;
@end

@implementation GPRNode (DotLanguage)

- (NSString *)gpr_dotString
{
    return [NSString stringWithFormat:@"  gpr_%p[label=\"%@\"]", self, self.name];
}

@end

////////////////////////////////////////////////////////////////////////

// For Swift Protocol Extension
static inline NSString *transformDotString(id<GPREdge> self)
{
    return [NSString stringWithFormat:@"  gpr_%p -> er_%p[label=\"%@\"]", self.from, self.to, self.name];
}

@interface GPRNodeGraphVisitor : NSObject <GPRNodeVisitor>
@property (nonatomic, readonly) NSMutableSet<GPRNode *> *nodes;
@property (nonatomic, readonly) NSMutableSet<id<GPRTransformEdge>> *transforms;
- (NSString *)dotFile;
@end

@implementation GPRNodeGraphVisitor

- (instancetype)init
{
    if (self = [super init]) {
        _nodes = [NSMutableSet set];
        _transforms = [NSMutableSet set];
    }
    
    return self;
}

- (BOOL) visitNode:(GPRNode *)node deep:(NSInteger)deep
{
    [self.nodes addObject:node];
    return NO;
}

- (BOOL) visitTransform:(id<GPRTransformEdge>)transform
{
    [self.transforms addObject:transform];
    return NO;
}

- (NSString *) dotFile
{
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"digraph G {\n  node [peripheries=2 style=filled color=\"#eecc80\"]\n  edge [color=\"sienna\" fontcolor=\"black\"] \n"];
    
    [result appendString:[[[GP_NEW_SEQ(self.transforms) map:^id _Nonnull(id<GPRTransformEdge> _Nonnull value) {
        return transformDotString(value);
    }] as:NSArray.class] componentsJoinedByString:@"\n"]];
    [result appendString:@"\n"];
    
    [result appendString:[[[GP_NEW_SEQ(self.nodes) map:^id _Nonnull(GPRNode * _Nonnull value) {
        return value.gpr_dotString;
    }] as:NSArray.class] componentsJoinedByString:@"\n"]];
    
    [result appendString:@"\n}"];
    
    return result.copy;
}

@end

////////////////////////////////////////////////////////////////////////

@implementation GPRNode (Graph)

- (NSString *)graph {
    GPRNodeGraphVisitor *visitor = [GPRNodeGraphVisitor new];
    [self traversal:visitor];
    return [visitor dotFile];
}

@end
