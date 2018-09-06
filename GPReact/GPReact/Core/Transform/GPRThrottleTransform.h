//
//  GPRThrottleTransform.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRTransform.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPRThrottleTransform : GPRTransform
- (instancetype)initWithThrottle:(NSTimeInterval)timeInterval on:(dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
