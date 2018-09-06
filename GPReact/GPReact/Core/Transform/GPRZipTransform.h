//
//  GPRZipTransform.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRTransform.h"

NS_ASSUME_NONNULL_BEGIN

@class GPSQueue;
@class GPRZipTransformGroup;

@interface GPRZipTransform : GPRTransform
@property (nonatomic, readonly, strong) GPSQueue *nextQueue;
@property (atomic, readwrite, strong, nullable) GPRZipTransformGroup *group;
@end

NS_ASSUME_NONNULL_END
