//
//  GPRPathTrampoline.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GPRMutableNode;

@interface GPRPathTrampoline : NSObject

- (instancetype)initWithTarget:(NSObject *)target;

- (void)setObject:(GPRMutableNode *)node forKeyedSubscript:(NSString *)keyPath;
- (GPRMutableNode *)objectForKeyedSubscript:(NSString *)keyPath;
@end

NS_ASSUME_NONNULL_END
