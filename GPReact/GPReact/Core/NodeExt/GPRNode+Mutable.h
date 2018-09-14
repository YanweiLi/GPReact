//
//  GPRNode+Mutable.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"
NS_ASSUME_NONNULL_BEGIN
@class GPRMutableNode<T>;

@interface GPRNode <T> (Mutable)
/**
 Modifies the receiver into mutable status
 @note The returned node is the same instance with the receiver.
 
 @return    Mutable node
 */
- (GPRMutableNode<T> *) mutableify;
@end
NS_ASSUME_NONNULL_END
