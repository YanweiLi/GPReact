//
//  ViewController.m
//  GPReactDemo
//
//  Created by Liyanwei on 2018/8/30.
//  Copyright © 2018年 Liyanwei. All rights reserved.
//

#import "ViewController.h"
#import <GPReact/GPReact.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // node
    [self newNode];
    // mutable node
    [self newMultableNode];
    // observe
    [self observeNextValue];
}

- (void) newNode
{
    GPRNode* node1 = [[GPRNode alloc] init];
    
    GPRNode<NSString*>* node2 = [GPRNode value:@"123"];
    GPRNode<NSNumber*>* node3 = [GPRNode value:@123456];
    
    NSLog(@"newNode : %@ , %@ , %@" , node1 , node2 , node3);
    
}

- (void) newMultableNode
{
    GPRMutableNode* node1 = [[GPRMutableNode alloc] init];
    
    GPRMutableNode<NSString*>* node2 = [GPRMutableNode value:@"123"];
    GPRMutableNode<NSNumber*>* node3 = [GPRMutableNode value:@123456];
    
    NSLog(@"newMultableNode : %@ , %@ , %@" , node1 , node2 , node3);
}

- (void) node2Mutable
{
    GPRNode<NSString*>* node2 = [GPRNode value:@"123"];
    GPRMutableNode<NSString*>* node3 = node2.mutableCopy;
    
    NSLog(@"node2Mutable : %@" , node3);
}

- (void) observeNextValue
{
    GPRMutableNode<NSNumber*>* node1 = [GPRMutableNode value:@1];
    NSObject* listener = [[NSObject alloc] init];
    NSLog(@"listener=%p" , listener);
    
    [[node1 listenedBy:listener] withBlock:^(NSNumber * _Nullable next) {
        NSLog(@"next = %@" , next);
    }];
    
    node1.value = @2;
    
    [node1 clean];
    node1.value = @3;
    
    listener = nil;
    node1.value = @4;
}

@end
