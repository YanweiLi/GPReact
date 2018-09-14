//
//  GPRCancelableBag.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPRCancelableBagProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GPRCancelableBag : NSObject <GPRCancelableBagProtocol>
/**
 Gets the instance which is able to implement cancel action for EZRCancelable object in batch.
 @return    EZRCancelableBag instance
 */
+ (instancetype) bag;
@end

NS_ASSUME_NONNULL_END
