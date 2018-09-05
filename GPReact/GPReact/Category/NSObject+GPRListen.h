//
//  NSObject+GPRListen.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class GPRNode;
@class GPRListenContext;

@interface NSObject (GPRListen)

/**
 Observes a GPRNode, and uses the return GPRListenContex object to add additional action.
 If additional actions were added, the GPRNode is holded by current object. The holding relationship will be released when the current object is being destroyed.
 Since Objective-C do not support method genericity, so this method is not able to transmit genericity to GPRListenContext instance.
 We suggest using 'ListenedBy:' method defined in GPRNode+Listen, which is able to transmit genericity, for the convenience of type inferences for later API.
 
 @see - [GPRNode+Listen ListenedBy:]
 @param node        Node being listened
 @return            GPRListenContext instance that can be attached additional actions
 */
- (GPRListenContext *) listen:(GPRNode *)node;

/**
 Stops observing node
 
 @param node        Node being listened
 */
- (void) stopListen:(GPRNode *)node;
@end

NS_ASSUME_NONNULL_END
