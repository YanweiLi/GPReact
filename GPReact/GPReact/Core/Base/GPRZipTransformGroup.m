//
//  GPRZipTransformGroup.m
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRZipTransformGroup.h"
#import <GPFoundation/GPFoundation.h>
#import "GPRZipTransform.h"
#import "GPREmpty.h"
#import "GPRMarcoDefine.h"

@interface GPRZipTransformGroup ()
@property (atomic, strong) NSArray<GPSWeakReference<GPRZipTransform *> *> *transforms;
@end

@implementation GPRZipTransformGroup
{
    NSUInteger _transformsCount;
}

- (instancetype) initWithTransforms:(NSArray<GPRZipTransform *> *)transforms
{
    NSParameterAssert(transforms);
    if (self = [super init]) {
        _transformsCount = transforms.count;
        _transforms = [[GP_NEW_SEQ(transforms) map:^GPSWeakReference<GPRZipTransform *> * _Nonnull(GPRZipTransform * _Nonnull item) {
            item.group = self;
            return [GPSWeakReference reference:item];
        }] as:NSMutableArray.class];
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
    for (GPSWeakReference<GPRZipTransform *> * _Nonnull obj in self.transforms) {
        GPRZipTransform *transform = obj.reference;
        if GPR_Unlikely(obj.reference == nil) {
            self.transforms = nil;
            return GPREmpty.empty;
        }
        
        GPSQueue *queue = transform.nextQueue;
        if (queue.empty) {
            return GPREmpty.empty;
        }
        
        id front = queue.front;
        if GPR_Unlikely(front == GPREmpty.empty) {
            return GPREmpty.empty;
        } else {
            tuple[index++] = front;
        }
    }
    
    for (GPSWeakReference<GPRZipTransform *> * _Nonnull obj in self.transforms) {
        [obj.reference.nextQueue dequeue];
    }
    
    return tuple;
}

- (void)removeTransform:(GPRZipTransform *)transform
{
    self.transforms = nil;
}

@end
