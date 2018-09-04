//
//  GPRBlockCancelable.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPRCancelable.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GPRCancelBlockType)(void);

@interface GPRBlockCancelable : NSObject <GPRCancelable>

/**
 Object which executes cancel action using Block, when a cancel method is invoked, the block will be called
 
 @param block   Block representing the cancel action
 @return        GPRBlockCancelable instance
 */
- (instancetype)initWithBlock:(GPRCancelBlockType)block NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
