//
//  GPRTypeDefine.h
//  GPReact
//
//  Created by Liyanwei on 2018/9/5.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPFoundation/GPFoundation.h>

@class GPRNode;
@class GPTuple2;

typedef id _Nullable(^GPRMapBlock)(id _Nullable value);
typedef BOOL (^GPRConditionBlock)(id _Nullable value);
typedef GPRNode *_Nullable (^GPRFlattenMapBlock)(id _Nullable value);
typedef BOOL (^GPRFilterBlock)(id _Nullable value);
typedef GPTuple2<id<NSCopying>, id> * _Nonnull(^GPRSwitchMapBlock)(id _Nullable next);
typedef id _Nonnull(^GPRReduceBlock)(id _Nullable runningValue, id  _Nullable next);
typedef id _Nonnull(^GPRReduceWithIndexBlock)(id _Nullable runningValue, id  _Nullable next, NSUInteger index);
