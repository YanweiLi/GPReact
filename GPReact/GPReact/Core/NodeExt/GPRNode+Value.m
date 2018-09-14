//
//  GPRNode+Value.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode+Value.h"

@implementation GPRNode (Value)
- (id) valueWithDefault:(id)defaultValue
{
    return self.isEmpty ? defaultValue : self.value;
}

- (void) getValue:(void(NS_NOESCAPE ^)(id value))processBlock
{
    if (processBlock && (!self.isEmpty)) {
        processBlock(self.value);
    }
}
@end
