//
//  GPRCancelable.h
//  GPReact
//
//  Created by Liyanwei on 2018/8/31.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GPRCancelable <NSObject>
@required

/**
 Executes the cancel action
 */
- (void)cancel;
@end
