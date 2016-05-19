//
//  HCTemplet.h
//  HCTemplet
//
//  Created by Curry on 16/5/19.
//  Copyright © 2016年 curry. All rights reserved.
//

#import <AppKit/AppKit.h>

@class HCTemplet;

static HCTemplet *sharedPlugin;

@interface HCTemplet : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end