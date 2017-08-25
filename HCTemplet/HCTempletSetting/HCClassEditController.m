//
//  HCClassEditController.m
//  HCTemplet
//
//  Created by Curry on 16/5/16.
//  Copyright © 2016年 curry. All rights reserved.
//

#import "HCClassEditController.h"
#import "HCTempletManager.h"
@interface HCClassEditController ()<NSTextViewDelegate>
@property (nonatomic, weak) IBOutlet NSTextField             *classNameTextField;
@property (nonatomic, weak) IBOutlet NSPopUpButton           *suffixButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView     *fileTextView;
@property (nonatomic, weak) IBOutlet NSButton                *cancelButton;
@property (nonatomic, weak) IBOutlet NSButton                *saveButton;

@property (nonatomic, strong) HCTempletManager  *templetManager;
@end

@implementation HCClassEditController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.templetManager.completionName = _templetName;
    _classNameTextField.cell.enabled = !_isEdit;
    _suffixButton.cell.enabled = !_isEdit;
    [_suffixButton setAction:@selector(suffixChangeSelector:)];
    [_suffixButton setTarget:self];
    
    // 编辑
    if (_isEdit) {
        [self setClassNameAndSuffixType];
        [self loadClassFileInfoText];
    }
    else {
        // 新增
        [self suffixChangeSelector:_suffixButton];
        if (self.templetManager.tempateType == HCTempateFileTypeSystem) {
            _classNameTextField.cell.enabled = NO;
            _classNameTextField.stringValue = _templetName;
        }
    }
}

// 编辑是根据类名后缀显示suffixButton文案
- (void)setClassNameAndSuffixType
{
    NSString *className = _className;
    if ([_className hasSuffix:@".h"]) {
        className = [self replacingString:className empty:@".h"];
        [_suffixButton selectItem:[_suffixButton itemAtIndex:0]];
    }else if ([_className hasSuffix:@".m"]){
        className = [self replacingString:className empty:@".m"];
        [_suffixButton selectItem:[_suffixButton itemAtIndex:1]];
    }else if ([_className hasSuffix:@".swift"]){
        className = [self replacingString:className empty:@".swift"];
        [_suffixButton selectItem:[_suffixButton itemAtIndex:2]];
    }
    className = [self replacingString:className empty:@"___FILEBASENAME___"];
    
    if (_templetManager.tempateType == HCTempateFileTypeCustom) {
        _classNameTextField.stringValue = className;
    }
    else {
        _classNameTextField.stringValue = _templetName;
    }
}

// 加载文件内容
- (void)loadClassFileInfoText
{
    NSError *error = nil;
    NSString *filePath = nil;
    NSString *text = nil;
    if (_templetManager.tempateType == HCTempateFileTypeCustom) {
        filePath = [_templetManager.fileTemplatesPath stringByAppendingPathComponent:_className];
    }
    else if (_templetManager.tempateType == HCTempateFileTypeSystem) {
        filePath = [_templetManager.systempTempatePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",_templetName, _className]];
    }
    text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        _fileTextView.string = text;
    }
}

// 保存文件内容
- (IBAction)saveClassFile:(id)sender
{
    NSString *suffix = [_suffixButton itemTitleAtIndex:_suffixButton.indexOfSelectedItem];
    if (_classNameTextField.stringValue.length > 0 && suffix.length >0) {
        NSString *fileName = [_templetManager createClassName:_classNameTextField.stringValue suffix:suffix];
        if (self.templetManager.tempateType == HCTempateFileTypeCustom) {
            [_templetManager createClassFileWithPath:_templetManager.fileTemplatesPath name:fileName infoString:_fileTextView.string];
        }
        else if (self.templetManager.tempateType == HCTempateFileTypeSystem) {
            NSString *className = self.className ? : [NSString stringWithFormat:@"___FILEBASENAME___.%@", suffix];
            [_templetManager createClassFileWithPath:[_templetManager.systempTempatePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/",_templetName]] name:className infoString:_fileTextView.string];
        }
        [self close];
        if (_saveBlock) {
            _saveBlock(fileName);
        }
    }
}

// 切换后缀名是加载不同默认模板数据
- (void)suffixChangeSelector:(NSPopUpButton *)sender
{
    NSString *classText = @"";
    switch (sender.indexOfSelectedItem) {
        case 0:
            classText = [self classInfoTextForPath:self.templetManager.egClassHPath];
            break;
        case 1:
            classText = [self classInfoTextForPath:self.templetManager.egClassMPath];
            break;
        case 2:
            classText = [self classInfoTextForPath:self.templetManager.egClassSPath];
            break;
        default:
            break;
    }
    _fileTextView.string = classText;
}

- (IBAction)cancel:(id)sender
{
    [self close];
}

- (NSString *)classInfoTextForPath:(NSString *)path
{
    NSError *error = nil;
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
}

- (NSString *)replacingString:(NSString *)className empty:(NSString *)string
{
    return [className stringByReplacingOccurrencesOfString:string withString:@""];
}

#pragma mark - Getters & Setters
- (HCTempletManager *)templetManager
{
    if (!_templetManager) {
        _templetManager = [HCTempletManager sharedInstance];
    }
    return _templetManager;
}
@end
