//
//  GPRListenContext+Private.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPRListenContext.h"

@class GPRNode;

NS_ASSUME_NONNULL_BEGIN

@interface GPRListenContext  (Private)
- (instancetype)initWithNode:(__weak GPRNode *)node listener:(__weak id)listener;
@end

NS_ASSUME_NONNULL_END
