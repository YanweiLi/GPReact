//
//  GPRMarcoDefine.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//


#import <Foundation/Foundation.h>

#ifndef GPR_MARCO_DEFINE_H_
#define GPR_MARCO_DEFINE_H_
// 宏定义
#import <GPFoundation/GPFoundation.h>

#define GPRNodeExceptionName  @"GPRNodeExceptionName"

//////////////////////////////////////////////////////
// cpu 流水线，优化指令
// branch prediction
#define GPR_BRANCH_PREDICTION

#ifdef GPR_BRANCH_PREDICTION
#define GPR_Likely(x)       (__builtin_expect(!!(x), 1))
#define GPR_Unlikely(x)     (__builtin_expect(!!(x), 0))
#define GPR_LikelyYES(x)    (__builtin_expect(x, YES))
#define GPR_LikelyNO(x)     (__builtin_expect(x, NO))
#else
#define GPR_Likely(x)       (x)
#define GPR_Unlikely(x)     (x)
#define GPR_LikelyYES(x)    (x)
#define GPR_LikelyNO(x)     (x)
#endif /* GPR_BRANCH_PREDICTION */

//////////////////////////////////////////////////////
// 其他宏

#define _GPRCombine(...)    \
((GP_CONCAT(GPRMapEachNode, GP_ARG_COUNT(__VA_ARGS__)) *)[GPRNode combine:@[__VA_ARGS__]])

#define _GPRZip(...)        \
((GP_CONCAT(GPRMapEachNode, GP_ARG_COUNT(__VA_ARGS__)) *)[GPRNode zip:@[__VA_ARGS__]])

#define _GPR_BLOCK_ARG(index)           GP_CONCAT(arg, index)
#define _GPR_BLOCK_ARG_DEF(index)       id GP_CONCAT(arg, index)
#define _GPR_BLOCK_DEF(N)               id (^)(GP_FOR_COMMA(N, _GPR_BLOCK_ARG_DEF))

// GPRMapEachNode##N
#define _GPR_DEF_REDUCE_VALUE(N)                                    \
@interface GP_CONCAT(GPRMapEachNode, N) : GPRNode                   \
- (GPRNode *)mapEach:(_GPR_BLOCK_DEF(N))block;                      \
@end

#define _GPR_DEF_REDUCE_VALUE_ITER(index)                           \
_GPR_DEF_REDUCE_VALUE(GP_INC(index))

#define GPR_MapEachFakeInterfaceDef(N)                              \
GP_FOR(N, _GPR_DEF_REDUCE_VALUE_ITER, ;)

#define _GPR_KeyPath(OBJ, PATH)                                     \
(((void)(NO && ((void)OBJ.PATH, NO)), @# PATH))

#define _GPR_PATH(TARGET, KEYPATH)                                  \
TARGET.gpr_path[_GPR_KeyPath(TARGET, KEYPATH)]


#define GPR_THROW(NAME, REASON, INFO)                               \
NSException *exception = [[NSException alloc] initWithName:NAME reason:REASON userInfo:INFO]; @throw exception;

#define GPRWeakify(...)                                             \
GPR_keywordify                                                      \
GP_FOR_EACH(GPR_weakify_, ,__VA_ARGS__)


#define GPRStrongify(...)                                           \
GPR_keywordify                                                      \
_Pragma("clang diagnostic push")                                    \
_Pragma("clang diagnostic ignored \"-Wshadow\"")                    \
GP_FOR_EACH(GPR_strongify_, , __VA_ARGS__)                          \
_Pragma("clang diagnostic pop")


#define GPR_weakify_(INDEX, VAR)                                    \
__weak __typeof__(VAR) GP_CONCAT(VAR, _weak_) = (VAR);

#define GPR_strongify_(INDEX, VAR)                                  \
__strong __typeof__(VAR) VAR = GP_CONCAT(VAR, _weak_);

#if DEBUG
#define GPR_keywordify autoreleasepool {}
#else
#define GPR_keywordify try {} @catch (...) {}
#endif


#endif /* GPR_MARCO_DEFINE_H_ */
