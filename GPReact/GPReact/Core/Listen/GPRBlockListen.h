//
//  GPRBlockListen.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GPRListen.h"

NS_ASSUME_NONNULL_BEGIN

@class GPRSenderList;
typedef void(^GPRListenBlockType)(id _Nullable next, GPRSenderList *senderList, id _Nullable context);

@interface GPRBlockListen : GPRListen
- (instancetype)initWithBlock:(GPRListenBlockType)block NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
