//
//  GPRTransform.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPRTransformEdge.h"

@class GPRSenderList;

NS_ASSUME_NONNULL_BEGIN

@interface GPRTransform : NSObject <GPRTransformEdge>

/**
 The transform method how the upstream value change affects downstream node.
 Sub class needs to call super implementation when customizing data processing method.
 
 If the block didn't need to capture super in your sub class implementation,
 simply call super, just like GPRMapTransform. for example:
 
 <pre>@textblock
 
 - (void)next:(id)value from:(GPRSenderList *)senderList {
 if (_block) {
 [super next:_block(value) from:senderList];
 }
 }
 
 @/textblock</pre>
 
 If the block needed to capture super in your sub class implementation,
 call self indirectly due to the implicit capture, just like GPRFlattenTransform. for example:
 
 <pre>@textblock
 
 
 - (void)next:(id)value from:(GPRSenderList *)senderList {
 GPRNode *node = _block(value);
 [self.cancelable cancel];
 
 @GPr_weakify(self)
 self.cancelable = [node listen:^(id  _Nullable next) {
 @gpr_strongify(self)
 [self _superNext:next from:senderList];
 }];
 }
 
 - (void)_superNext:(id)value from:(GPRSenderList *)senderList {
 [super next:value from:senderList];
 }
 
 @/textblock</pre>
 
 @param value           The latest value
 @param senderList      A list of sender node, used in judging whether a circle occurs
 @param context         Context that comes from upstream node
 */
- (void)next:(nullable id)value from:(GPRSenderList *)senderList context:(nullable id)context;

@end

NS_ASSUME_NONNULL_END
