//
//  GPRNextReceiver.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GPRNextReceiver <NSObject>
@required
/**
 Transfers value object to downstream node by a given sender list and a context.
 The sender list contains all the nodes that had been transferred the value object.
 The given context is used for taking an external object.
 
 @param value       Latest value
 @param senderList  List of node value senders, used for retrospecting the sources of values
 @param context     Context passed by user
 */
- (void)next:(nullable id)value from:(nonnull EZRSenderList *)senderList context:(nullable id)context;
@end
