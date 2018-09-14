//
//  NSObject+GPRExt.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "NSObject+GPRExt.h"
#import "GPRMutableNode.h"
#import "GPRPathTrampoline.h"
#import <objc/runtime.h>

static void *GPR_PathTrampolineKey = &GPR_PathTrampolineKey;

@implementation NSObject (GPRExtension)

- (GPRPathTrampoline *) gpr_path
{
    GPRPathTrampoline *pathTrampoline = objc_getAssociatedObject(self, GPR_PathTrampolineKey);
    
    if (!pathTrampoline) {
        @synchronized(self) {
            pathTrampoline = objc_getAssociatedObject(self, GPR_PathTrampolineKey);
            if (!pathTrampoline) {
                pathTrampoline = [[GPRPathTrampoline alloc] initWithTarget:self];
                objc_setAssociatedObject(self, GPR_PathTrampolineKey, pathTrampoline, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    return pathTrampoline;
}

- (GPRNode *) gpr_toNode
{
    return [GPRNode value:self];
}

- (GPRMutableNode *) gpr_toMutableNode
{
    return [GPRMutableNode value:self];
}

@end
