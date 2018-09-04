//
//  GPRCancelableBagProtocol.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRCancelable.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GPRCancelableBagProtocol <NSObject>
/**
 Puts the cancelable object into the bag, for the purpose of later batch operation.
 
 @param cancelable  Object which can be cancelled
 */
- (void)addCancelable:(id<GPRCancelable>)cancelable;

/**
 Removes the cancelable object from the bag
 
 @param cancelable  Object which can be cancelled
 */
- (void)removeCancelable:(id<GPRCancelable>)cancelable;
@end

NS_ASSUME_NONNULL_END
