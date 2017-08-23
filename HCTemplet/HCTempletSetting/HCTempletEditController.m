//
//  HCTempletEditController.m
//  HCTemplet
//
//  Created by Curry on 16/5/11.
//  Copyright © 2016年 curry. All rights reserved.
//

#import "HCTempletEditController.h"
#import "HCTempletManager.h"

@interface HCTempletEditController ()
@property (nonatomic, weak) IBOutlet NSTextField    *templetNameTextField;
@property (nonatomic, weak) IBOutlet NSPopUpButton  *languageButton;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextView     *descriptionTextView;
@property (nonatomic, weak) IBOutlet NSButton       *cancelButton;
@property (nonatomic, weak) IBOutlet NSButton       *saveButton;

@property (nonatomic, strong) NSMutableDictionary       *templetInfo;
@property (nonatomic, strong) NSString                  *className;
@property (nonatomic, strong) HCTempletManager          *templistPlist;
@end

@implementation HCTempletEditController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName className:(NSString *)name
{
    if (self = [self initWithWindowNibName:windowNibName]) {
        if (name.length) {
            self.className = name;
            self.templetInfo = [self.templistPlist fileTempletInfoPlistWithName:name];
        }
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self setupView];
}

- (void)setupView
{
    if (self.templetInfo) {
        _templetNameTextField.stringValue = _templetInfo[@"DefaultCompletionName"];
        
    }
}

- (void)saveSystemTempateFile {
    if (_templetNameTextField.stringValue.length > 0) {
        NSString *language = [_languageButton itemTitleAtIndex:_languageButton.indexOfSelectedItem];
        NSString *folderName = [NSString stringWithFormat:@"%@%@",_templetNameTextField.stringValue,language];
        // 插入到plist文件
        NSString *path = self.templistPlist.systempTempatePath;
        NSDictionary *dic = [self.templistPlist systemTemplatePlistData];
        NSArray *optionArray = dic[@"Options"];
        NSMutableArray *valueArray = nil;
        for (NSDictionary *dic in optionArray) {
            for (NSString *key in dic.allKeys) {
                if ([key isEqualToString:@"Identifier"] &&
                    [dic[@"Identifier"] isEqualToString:@"cocoaTouchSubclass"]) {
                    valueArray = dic[@"Values"];
                }
            }
        }
        [valueArray addObject:_templetNameTextField.stringValue];
        NSLog(@"%@",valueArray);
        [self.templistPlist saveTemplateInfoPlistData:dic path:path];
        // 创建文件夹
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directryPath = [path stringByAppendingPathComponent:folderName];
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)saveCustomTempateFile {
    NSString *language = [_languageButton itemTitleAtIndex:_languageButton.indexOfSelectedItem];
    if (_templetInfo) {
        _templetInfo[@"AllowedTypes"] = @[[NSString stringWithFormat:@"public.%@-source",language]];
        _templetInfo[@"DefaultCompletionName"] = _templetNameTextField.cell.title?:@"FileTemplet";
        _templetInfo[@"Description"] = _descriptionTextView.string.length?_descriptionTextView.string:_templetInfo[@"Description"];
        NSArray *options = _templetInfo[@"Options"];
        NSMutableDictionary *languageDic = options.lastObject;
        languageDic[@"Default"] = language;
        [self.templistPlist saveTemplateInfoPlistData:_templetInfo path:self.templistPlist.fileTemplatesPath];
        [self.templistPlist deleteXCTemplateForName:self.className path:self.templistPlist.fileTemplatesPath];
    }else
    {
        self.templistPlist.completionName = _templetNameTextField.cell.title;
        self.templistPlist.fileLanguage = (HCFileLanguageType)_languageButton.indexOfSelectedItem;
        [self.templistPlist createTemplateInfoPlist];
    }
}

- (IBAction)saveTempletInfoData:(id)sender
{
    if (self.templistPlist.tempateType == HCTempateFileTypeSystem) {
        [self saveSystemTempateFile];
    }
    else if (self.templistPlist.tempateType == HCTempateFileTypeCustom) {
        [self saveCustomTempateFile];
    }
    if (_saveBlock) {
        _saveBlock(_templetNameTextField.cell.title);
    }
    [self close];
}

- (IBAction)cancelTempletEdit:(id)sender
{
    [self close];
}

#pragma mark - Getters & Setters
- (HCTempletManager *)templistPlist
{
    if (!_templistPlist) {
        _templistPlist = [HCTempletManager sharedInstance];
    }
    return _templistPlist;
}
@end
