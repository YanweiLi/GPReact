//
//  GPRCancelableBag.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRCancelableBag.h"
#import "GPRMarcoDefine.h"
#import "GPRCancelable.h"
#import <GPFoundation/GPFoundation.h>

@implementation GPRCancelableBag
{
    GPSArray<id<GPRCancelable>> *_cancelBag;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _cancelBag = [GPSArray new];
    }
    
    return self;
}

+ (instancetype) bag
{
    return [[self alloc] init];
}

- (void) cancel
{
    @synchronized (self) {
        [GP_NEW_SEQ(_cancelBag) forEach:^(id<GPRCancelable>  _Nonnull value) {
            [value cancel];
        }];
        
        [_cancelBag removeAllObjects];
    }
}

- (void) addCancelable:(id<GPRCancelable>)cancelable
{
    NSParameterAssert(cancelable);
    if (!cancelable) { return; }
    [_cancelBag addObject:cancelable];
}

- (void) removeCancelable:(id<GPRCancelable>)cancelable
{
    NSParameterAssert(cancelable);
    if (!cancelable) { return; }
    [_cancelBag removeObject:cancelable];
}

- (void) dealloc
{
    [GP_NEW_SEQ(_cancelBag) forEach:^(id<GPRCancelable>  _Nonnull value) {
        [value cancel];
    }];
}

@end
