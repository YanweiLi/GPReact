//
//  GPRSenderList.m
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRSenderList.h"

@implementation GPRSenderList

- (instancetype) init
{
    if (self = [super init]) {
    }
    return self;
}

- (instancetype) initWithSender:(id)value
{
    if (self = [super init]) {
        _value = value;
    }
    return self;
}

+ (instancetype) senderListWithSender:(id)value
{
    return [[self alloc] initWithSender:value];
}

+ (instancetype) senderListWithArray:(NSArray *)array
{
    GPRSenderList *list = [[GPRSenderList alloc] init];
    for (id value in array) {
        list = [list appendNewSender:value];
    }
    return list;
}

- (instancetype) appendNewSender:(id)value
{
    GPRSenderList *newSenderList = [GPRSenderList senderListWithSender:value];
    newSenderList->_prev = self;
    return newSenderList;
}

- (BOOL) contains:(id)obj
{
    GPRSenderList *list = self;
    while (list) {
        if (list.value == obj) {
            return YES;
        }
        list = list.prev;
    }
    return NO;
}
@end
