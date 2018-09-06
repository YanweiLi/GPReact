//
//  GPRDistinctTransform.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRDistinctTransform.h"
#import "GPRNode+Private.h"

@implementation GPRDistinctTransform

- (instancetype) init
{
    if (self = [super init]) {
        [super setName:@"Distinct"];
    }
    return self;
}

- (void) next:(id)value
         from:(GPRSenderList *)senderList
      context:(nullable id)context
{
    if (self.to.value == value || [self.to.value isEqual:value]) {
        return;
    }
    
    [super next:value from:senderList context:context];
}

@end
