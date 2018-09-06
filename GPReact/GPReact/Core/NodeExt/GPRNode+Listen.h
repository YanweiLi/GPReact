//
//  GPRNode+Listen.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"

NS_ASSUME_NONNULL_BEGIN
@class GPRListenContext<T>;

@interface GPRNode <T> (Listen)
/**
 Listened by listener, able to add additional action through the method of returned GPRListenContext object.
 If additional actions were added, the current node is holded by listener,
 the holding relationship will be released when the listener is being destroyed.
 
 @param listener    Listener
 @return            GPRListenContext instance which can attach actions
 */
- (GPRListenContext<T> *)listenedBy:(id)listener;
@end

NS_ASSUME_NONNULL_END
