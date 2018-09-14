//
//  GPRNode+Value.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/14.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "GPRNode.h"
NS_ASSUME_NONNULL_BEGIN
@interface GPRNode <T> (Value)

/**
 If value of current node were GPREmpty, return the passing 'defaultValue', otherwise, return current value.
 
 @param defaultValue    Default value
 @return                value after calculation
 */
- (nullable T) valueWithDefault:(nullable T)defaultValue;

/**
 Block will be executed if the node has current value. The 'processBlock' is non-escaping block and will not capture variables.
 Like 'if let' in Swift
 
 <pre>@textblock
 
 var o: String?
 
 if let _ = o {
 // do something
 }
 
 @/textblock</pre>
 
 @param processBlock    Block for processing action, and parameter of block is current value of node
 */
- (void) getValue:(void(NS_NOESCAPE ^ _Nullable)(_Nullable T value))processBlock;
@end
NS_ASSUME_NONNULL_END
