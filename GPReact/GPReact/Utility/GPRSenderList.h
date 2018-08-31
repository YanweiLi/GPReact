//
//  GPRSenderList.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface GPRSenderList : NSObject

@property (nonatomic, readonly, strong) id value;
@property (nonatomic, readonly, strong) GPRSenderList *prev;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithSender:(id)value NS_DESIGNATED_INITIALIZER;
+ (instancetype)senderListWithSender:(id)value;
+ (instancetype)senderListWithArray:(NSArray *)array;

- (GPRSenderList *)appendNewSender:(id)value;
- (BOOL)contains:(id)obj;

@end

NS_ASSUME_NONNULL_END
