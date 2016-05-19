//
//  HCTemplet.m
//  HCTemplet
//
//  Created by Curry on 16/5/19.
//  Copyright © 2016年 curry. All rights reserved.
//

#import "HCTemplet.h"
#import "HCFileSettingController.h"
@interface HCTemplet()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong, readwrite) HCFileSettingController *settingWindow;
@end

@implementation HCTemplet

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    // Create menu items, initialize UI, etc.
    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenuItem *pluginsMenuItem = [mainMenu itemWithTitle:@"Plugins"];
    if (!pluginsMenuItem) {
        pluginsMenuItem = [[NSMenuItem alloc] init];
        pluginsMenuItem.title = @"Plugins";
        pluginsMenuItem.submenu = [[NSMenu alloc] initWithTitle:pluginsMenuItem.title];
        NSInteger windowIndex = [mainMenu indexOfItemWithTitle:@"Window"];
        [mainMenu insertItem:pluginsMenuItem atIndex:windowIndex];
    }
    NSMenuItem *mainMenuItem = [[NSMenuItem alloc] initWithTitle:@"HCTemplet"
                                                          action:@selector(showSettingWindow)
                                                   keyEquivalent:@""];
    [mainMenuItem setTarget:self];
    [pluginsMenuItem.submenu addItem:mainMenuItem];
}

- (void)showSettingWindow {
    self.settingWindow = [[HCFileSettingController alloc] initWithWindowNibName:@"HCFileSettingController"];
    [self.settingWindow showWindow:self.settingWindow];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
