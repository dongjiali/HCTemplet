//
//  HCTempletEditController.h
//  HCTemplet
//
//  Created by Curry on 16/5/11.
//  Copyright © 2016年 curry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^save_templet_block)(NSString *className);

@interface HCTempletEditController : NSWindowController

@property (nonatomic, copy) save_templet_block saveBlock;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName className:(NSString *)name;
@end

