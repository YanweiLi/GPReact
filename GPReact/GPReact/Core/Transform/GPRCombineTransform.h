//
//  GPRCombineTransform.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRTransform.h"

NS_ASSUME_NONNULL_BEGIN
@class GPRCombineTransformGroup;

@interface GPRCombineTransform : GPRTransform
@property (atomic, readwrite, strong, nullable) GPRCombineTransformGroup *group;
@property (atomic, readonly, strong, nullable) id lastValue;
@end
NS_ASSUME_NONNULL_END
