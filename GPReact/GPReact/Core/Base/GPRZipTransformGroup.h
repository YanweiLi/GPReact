//
//  GPRZipTransformGroup.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GPRZipTransform;

@interface GPRZipTransformGroup : NSObject
- (instancetype)initWithTransforms:(NSArray<GPRZipTransform *> *)transforms NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (id)nextValue;
- (void)removeTransform:(GPRZipTransform *)transform;
@end

NS_ASSUME_NONNULL_END
