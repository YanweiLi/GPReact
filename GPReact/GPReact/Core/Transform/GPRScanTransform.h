//
//  GPRScanTransform.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRTransform.h"
#import "GPRTypeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPRScanTransform : GPRTransform
- (instancetype)initWithStartValue:(id _Nullable)startValue
                       reduceBlock:(GPRReduceWithIndexBlock)block NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
