//
//  HCClassEditController.h
//  HCTemplet
//
//  Created by Curry on 16/5/16.
//  Copyright © 2016年 curry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HCTempletManager.h"
typedef void(^save_class_file_block)(NSString *className);

@interface HCClassEditController : NSWindowController

@property (nonatomic, copy) save_class_file_block saveBlock;
@property (nonatomic, copy) NSString *templetName;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, assign) BOOL isEdit;
@end
