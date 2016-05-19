//
//  NSObject_Extension.m
//  HCTemplet
//
//  Created by Curry on 16/5/19.
//  Copyright © 2016年 curry. All rights reserved.
//


#import "NSObject_Extension.h"
#import "HCTemplet.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[HCTemplet alloc] initWithBundle:plugin];
        });
    }
}
@end
