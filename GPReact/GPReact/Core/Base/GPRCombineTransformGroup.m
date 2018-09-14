//
//  GPRCombineTransformGroup.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRCombineTransformGroup.h"
#import <GPFoundation/GPFoundation.h>
#import "GPRCombineTransform.h"
#import "GPREmpty.h"
#import "GPRMarcoDefine.h"

@interface GPRCombineTransformGroup ()
@property (atomic, strong) NSArray<GPSWeakReference<GPRCombineTransform *> *> *transforms;
@end

@implementation GPRCombineTransformGroup
{
    NSUInteger _transformsCount;
}

- (instancetype) initWithTransforms:(NSArray<GPRCombineTransform *> *)transforms
{
    NSParameterAssert(transforms);
    if (self = [super init]) {
        _transformsCount = transforms.count;
        _transforms = [[GP_NEW_SEQ(transforms) map:^GPSWeakReference<GPRCombineTransform *> * _Nonnull(GPRCombineTransform * _Nonnull item) {
            item.group = self;
            return [GPSWeakReference reference:item];
        }] as:NSMutableArray.class]; // Never changed, so converting to mutable array is faster.
    }
    return self;
}

- (id) nextValue
{
    if (self.transforms.count != _transformsCount) {
        return GPREmpty.empty;
    }
    
    GPTupleBase *tuple = [GPTupleBase tupleWithCount:_transformsCount];
    NSUInteger index = 0;
    for (GPSWeakReference<GPRCombineTransform *> * _Nonnull obj in self.transforms) {
        GPRCombineTransform *transform = obj.reference;
        if (transform == nil) {
            self.transforms = nil;
            return GPREmpty.empty;
        }

        id last = transform.lastValue;
        if (last == GPREmpty.empty) {
            return GPREmpty.empty;
        } else {
            tuple[index++] = last;
        }
    }
    
    return tuple;
}

- (void) removeTransform:(GPRCombineTransform *)transform
{
    self.transforms = nil;
}

@end
