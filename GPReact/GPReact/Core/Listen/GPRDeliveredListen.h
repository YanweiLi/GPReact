//
//  GPRDeliveredListen.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRBlockListen.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPRDeliveredListen : GPRBlockListen
- (instancetype)initWithBlock:(GPRListenBlockType)block on:(dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithBlock:(GPRListenBlockType)block NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
