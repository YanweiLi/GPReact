//
//  GPRCombineTransformGroup.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GPRCombineTransform;
@interface GPRCombineTransformGroup : NSObject
- (instancetype)initWithTransforms:(NSArray<GPRCombineTransform *> *)transforms NS_DESIGNATED_INITIALIZER;

- (nullable id)nextValue;
- (void)removeTransform:(GPRCombineTransform *)transform;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
