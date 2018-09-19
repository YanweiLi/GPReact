//
//  GPRNode+Listen.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode+Listen.h"
#import "NSObject+GPRListen.h"
#import "GPRListenContext.h"

@implementation GPRNode (Listen)

- (GPRListenContext *) listenedBy:(id)listener
{
    return [listener listen:self];
}

@end
