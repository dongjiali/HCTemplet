//
//  HCFilesCollectionView.m
//  HCTemplet
//
//  Created by Curry on 16/5/17.
//  Copyright © 2016年 curry. All rights reserved.
//

#import "HCFilesCollectionView.h"
#import "HCTempletManager.h"
#define SelectoClassNameAction @"SelectoClassNameAction"
#define EditClassFileNameAction @"EditClassFileNameAction"


static const NSSize itemSize = {100, 120};

@interface HCFilesCollectionView()
@property(nonatomic , strong) HCCollectionItem *item;
@end

@implementation HCFilesCollectionView

- (void)awakeFromNib
{
    [self setSelectable:YES];
    [self setItemPrototype:self.item];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

#pragma mark - NSCollectionViewDelegate & NSCollectionViewDataSource

#pragma mark - Getters & Setters
- (void)setClassFileList:(NSArray *)classFileList
{
    _classFileList = classFileList;
    if (self.classFileList && self.classFileList.count) {
        [self setContent:self.classFileList];
    }else
    {
        [self setContent:@[]];
    }
}

- (HCCollectionItem *)item
{
    if (!_item) {
        _item = [[HCCollectionItem alloc]init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectoClassNameAction:) name:SelectoClassNameAction object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editselectoClassFileNameAction:) name:EditClassFileNameAction object:nil];
    }
    return _item;
}

- (void)editselectoClassFileNameAction:(NSNotification *)notification
{
    if (_editBlock) {
        _editBlock(notification.object);
    }
}

- (void)selectoClassNameAction:(NSNotification *)notification
{
    self.selectedClassFile = notification.object;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface HCCollectionItem()
@end

@implementation HCCollectionItem
- (void)loadView {
    [self setView:[[HCView alloc] initWithFrame:NSZeroRect]];
}

- (void)mouseDown:(NSEvent *)event {
    HCView *view = (HCView *)[self view];
    if (event.clickCount == 2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EditClassFileNameAction object:view.title];
    }else if (event.clickCount == 1)
    {
        [self setSelected:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:SelectoClassNameAction object:view.title];
    }
}

- (void)setSelected:(BOOL)selected
{
    HCView *view = (HCView *)[self view];
    [view setIsSelected:selected];
    [super setSelected:selected];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    if (representedObject) {
        HCView *view = (HCView *)[self view];
        view.title = representedObject;
        view.imagePath = [[HCTempletManager sharedInstance] classFilePathImageWithName:representedObject];
    }
}
@end



@interface HCView()
@property (nonatomic,strong) NSImageView    *imageView;
@property (nonatomic,strong) NSText         *titleLabel;
@end

@implementation HCView

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect imageRect = NSMakeRect(5,5,self.frame.size.width -10,self.frame.size.height -10);
    
    NSBezierPath* imageRoundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect:imageRect xRadius: 4 yRadius: 4];
    NSColor* fillColor = nil;
    NSColor* strokeColor = nil;
    
    if (_isSelected) {
        fillColor = [NSColor colorWithCalibratedRed: 0.851 green: 0.851 blue: 0.851 alpha: 1];
        strokeColor = [NSColor colorWithCalibratedRed: 0.408 green: 0.592 blue: 0.855 alpha: 1];
        
    }else{
        fillColor = [NSColor clearColor];
        strokeColor = [NSColor colorWithCalibratedRed: 0.749 green: 0.749 blue: 0.749 alpha: 1];
    }
    
    [fillColor setFill];
    [imageRoundedRectanglePath fill];
    [strokeColor setStroke];
    
    [super drawRect:dirtyRect];
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    [self setNeedsDisplay:YES];
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:(NSRect){frameRect.origin, itemSize}];
    if (self) {
        self.imageView = [[NSImageView alloc]initWithFrame:CGRectMake(25, 55, 50, 50)];
        [self addSubview:_imageView];
        
        self.titleLabel = [[NSText alloc] initWithFrame:CGRectMake(10, 15, 80, 30)];
        _titleLabel.editable = NO;
        _titleLabel.backgroundColor = [NSColor clearColor];
        _titleLabel.alignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    if (imagePath && imagePath.length) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
        [_imageView setImage:image];
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    if (title && title.length) {
        _titleLabel.string = [title stringByReplacingOccurrencesOfString:@"___FILEBASENAME___" withString:@""];;
    }
}
@end
