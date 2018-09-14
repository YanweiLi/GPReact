//
//  GPRCaseTransform.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <GPReact/GPReact.h>
NS_ASSUME_NONNULL_BEGIN
@interface GPRCaseTransform : GPRTransform
- (instancetype)initWithCaseKey:(nullable id<NSCopying>)key NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
