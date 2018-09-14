//
//  GPRNode+Mutable.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode+Mutable.h"
#import "GPRMutableNode+Private.h"

@implementation GPRNode (Mutable)

- (GPRMutableNode *) mutableify
{
    GPRMutableNode *node = (GPRMutableNode *)self;
    node.mutable = YES;
    return node;
}

@end
