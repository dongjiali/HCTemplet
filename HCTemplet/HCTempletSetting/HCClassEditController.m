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
@property (nonatomic, weak) IBOutlet NSTextField    *classNameTextField;
@property (nonatomic, weak) IBOutlet NSPopUpButton  *suffixButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView     *fileTextView;
@property (nonatomic, weak) IBOutlet NSButton       *cancelButton;
@property (nonatomic, weak) IBOutlet NSButton       *saveButton;
@property (nonatomic, weak) IBOutlet NSButton       *deleteButton;

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
    if (_isEdit) {
        [self setClassNameAndSuffixType];
        [self loadClassFileInfoText];
    }
    [self suffixChangeSelector:_suffixButton];
}

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
    _classNameTextField.stringValue = className;
}

- (NSString *)replacingString:(NSString *)className empty:(NSString *)string
{
    return [className stringByReplacingOccurrencesOfString:string withString:@""];
}

- (void)loadClassFileInfoText
{
    NSError *error=nil;
    NSString *filePath = [_templetManager.fileTemplatesPath stringByAppendingPathComponent:_className];
    NSString *text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    _fileTextView.string = text;
}

- (IBAction)saveClassFile:(id)sender
{
    NSString *suffix = [_suffixButton itemTitleAtIndex:_suffixButton.indexOfSelectedItem];
    if (_classNameTextField.stringValue.length > 0 && suffix.length >0) {
        NSString *fileNmae = [_templetManager createClassName:_classNameTextField.stringValue suffix:suffix];
        [_templetManager createClassFileWithName:fileNmae infoString:_fileTextView.string];
        [self close];
        if (_saveBlock) {
            _saveBlock(fileNmae);
        }
    }
}

- (IBAction)cancel:(id)sender
{
    [self close];
}

- (IBAction)deleteClassFile:(id)sender
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",self.templetManager.fileTemplatesPath,@""];
    if ([FileManager fileExistsAtPath:filePath]) {
        NSError *err;
        [FileManager removeItemAtPath:filePath error:&err];
    }
    [self close];
}

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

- (NSString *)classInfoTextForPath:(NSString *)path
{
    NSError *error = nil;
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
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
