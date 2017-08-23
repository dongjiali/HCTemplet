//
//  HCFileSettingController.m
//  HCTemplet
//
//  Created by Curry on 16/5/11.
//  Copyright © 2016年 curry. All rights reserved.
//

#import "HCFileSettingController.h"
#import "HCTempletManager.h"
#import "HCTempletEditController.h"
#import "HCFilesCollectionView.h"
#import "HCClassEditController.h"

@interface HCFileSettingController ()<NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, weak) IBOutlet NSTextField            *classInfoLabel;
@property (nonatomic, weak) IBOutlet NSButton               *addCalssBtn;
@property (nonatomic, weak) IBOutlet NSButton               *removeClassBtn;
@property (nonatomic, weak) IBOutlet NSTableView            *tableView;
@property (nonatomic, weak) IBOutlet NSPopUpButton          *popUpButton;
@property (nonatomic, weak) IBOutlet HCFilesCollectionView  *collectionView;

@property (nonatomic, strong) HCTempletEditController       *templetEditController;
@property (nonatomic, strong) HCClassEditController         *classEditController;
@property (nonatomic, strong) HCTempletManager        *fileTempletPlist;
@property (nonatomic, copy) NSMutableArray              *listOfFiles;
@property (nonatomic, copy) NSMutableArray              *classFiles;
@end

@implementation HCFileSettingController

#pragma mark - LifeCycle

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setHeaderView:nil];
    [self.tableView setGridStyleMask:NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask];
    [self.tableView setGridColor:[NSColor clearColor]];
    self.fileTempletPlist.tempateType = HCTempateFileTypeSystem;
    [self reloadTemplateData];
    
    [self classFileEditControllerBlock];
    
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method
- (void)reloadTemplateData {
    if (self.fileTempletPlist.tempateType == HCTempateFileTypeSystem) {
        [self reloadSystemTemplateData];
    }
    else if (self.fileTempletPlist.tempateType == HCTempateFileTypeCustom) {
        [self reloadCustomTemplateData];
    }
    [self.tableView reloadData];
}

- (void)reloadSystemTemplateData {
    NSArray *classArray = self.fileTempletPlist.systemClassValues;
    
    _listOfFiles = [NSMutableArray array];
    [_listOfFiles addObject:OCTitleName];
    [_listOfFiles addObjectsFromArray:classArray];
    [_listOfFiles addObject:SwiftTitleName];
    [_listOfFiles addObjectsFromArray:classArray];
    
    NSInteger spaceCount = _listOfFiles.count / 2;
    _classFiles = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSInteger i = 0; i < _listOfFiles.count; i++) {
        NSString *suffix = i < spaceCount ? @"Objective-C" : @"Swift";
        NSString *folderPath = [NSString stringWithFormat:@"%@%@%@/",self.fileTempletPlist.systempTempatePath, _listOfFiles[i], suffix];
        NSMutableArray *classFiles = [[NSMutableArray alloc]initWithArray:[self.fileTempletPlist classFilesForTemplet:_listOfFiles[i] path:folderPath]];
        [_classFiles addObject:classFiles];
    }
}

- (void)reloadCustomTemplateData {
    _listOfFiles = [[NSMutableArray alloc] initWithArray:[self.fileTempletPlist fileTempletsKeys]];
    _classFiles = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSString *key in _listOfFiles) {
        NSMutableArray *classFiles = [[NSMutableArray alloc]initWithArray:[self.fileTempletPlist classFilesForTemplet:key path:self.fileTempletPlist.fileTemplatesPath]];
        [_classFiles addObject:classFiles];
    }
}

- (void)reloadFileWithTemplet
{
    [self reloadTemplateData];
    NSInteger row = _tableView.selectedRow;
    if (row >= 0 && _classFiles.count > row) {
        _collectionView.classFileList = _classFiles[row];
    }else
    {
        _collectionView.classFileList = nil;
    }
}

- (void)deleteTemplateFileWithRow:(NSInteger)row {
    NSString *templetString = self.listOfFiles[row];
    if (self.fileTempletPlist.tempateType == HCTempateFileTypeSystem) {
        // 插入到plist文件
        NSString *path = self.fileTempletPlist.systempTempatePath;
        NSDictionary *dic = [self.fileTempletPlist systemTemplatePlistData];
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
        [valueArray removeObject:templetString];
        NSLog(@"%@",valueArray);
        [self.fileTempletPlist saveTemplateInfoPlistData:dic path:path];
        
        [self.fileTempletPlist deleteXCTemplateForName:templetString path:[NSString stringWithFormat:@"%@/%@Objective-C",self.fileTempletPlist.systempTempatePath,templetString]];
        [self.fileTempletPlist deleteXCTemplateForName:templetString path:[NSString stringWithFormat:@"%@/%@Swift",self.fileTempletPlist.systempTempatePath,templetString]];
    }
    else if (self.fileTempletPlist.tempateType == HCTempateFileTypeCustom) {
        [self.fileTempletPlist deleteXCTemplateForName:templetString path:self.fileTempletPlist.fileTemplatesPath];
    }
    [self reloadFileWithTemplet];
}

- (void)classFileEditControllerBlock
{
    __weak typeof(self) weakSelf = self;
    self.collectionView.editBlock = ^(NSString *className)
    {
        NSInteger row = weakSelf.tableView.selectedRow;
        if (row >= 0) {
            weakSelf.classEditController = [[HCClassEditController alloc]initWithWindowNibName:@"HCClassEditController"];
            weakSelf.classEditController.templetName = weakSelf.listOfFiles[row];
            weakSelf.classEditController.isEdit = YES;
            weakSelf.classEditController.className = className;
            [weakSelf showVlassEditControllerWindow];
        }
    };
}

- (void)changeClassViewStatusByTitle:(NSString *)title
{
    BOOL tag = [title isEqualToString:SwiftTitleName] || [title isEqualToString:OCTitleName];
    _classInfoLabel.hidden = tag;
    _addCalssBtn.hidden = tag;
    _removeClassBtn.hidden = tag;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = notification.object;
    NSInteger row = tableView.selectedRow;
    if (row >= 0) {
        
        NSInteger index = [self.listOfFiles indexOfObject:SwiftTitleName];
        _fileTempletPlist.fileLanguage = row < index ? HCFileLanguageTypeOC :
        HCFileLanguageTypeSwift;
        
        _fileTempletPlist.completionName = self.listOfFiles[row];
        self.collectionView.classFileList = self.classFiles[row];
        [self changeClassViewStatusByTitle:_fileTempletPlist.completionName];
    }
}

- (IBAction)changeTemplateAction:(NSPopUpButton *)button {
    self.fileTempletPlist.tempateType = (HCTempateFileType)button.selectedTag;
    [self reloadTemplateData];
}

- (IBAction)addNewTemplet:(id)sender {
    [self showEditControllerWithTempletName:@"" sender:sender];
}

- (IBAction)removeSelectedTemplet:(id)sender {
    NSInteger row = self.tableView.selectedRow;
    if (row >= 0) {
        __weak typeof(self) weakSelf = self;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Delete the Templet?"];
        [alert setInformativeText:@"Deleted Templet cannot be restored."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:self.window
                      completionHandler:^(NSModalResponse returnCode) {
                          if (returnCode == NSAlertFirstButtonReturn) {
                              [weakSelf deleteTemplateFileWithRow:row];
                          }
                      }];
    }
}

- (IBAction)editSelectedTemplet:(id)sender {
    NSInteger row = self.tableView.selectedRow;
    if (row >= 0) {
        NSString *templetString = _listOfFiles[row];
        [self showEditControllerWithTempletName:templetString sender:sender];
    }
}

- (void)showEditControllerWithTempletName:(NSString *)name sender:(id)sender {
    __weak typeof(self) weakSelf = self;
    _templetEditController = [[HCTempletEditController alloc] initWithWindowNibName:@"HCTempletEditController" className:name];
    
    NSRect windowFrame = [[self window] frame];
    NSRect prefsFrame = [[_templetEditController window] frame];
    prefsFrame.origin = NSMakePoint(windowFrame.origin.x + (windowFrame.size.width - prefsFrame.size.width) / 2.0,
                                    NSMaxY(windowFrame) - NSHeight(prefsFrame) - 20.0);
    
    _templetEditController.saveBlock = ^(NSString *className){
        [weakSelf reloadTemplateData];
    };
    [[_templetEditController window] setFrame:prefsFrame display:NO];
    [_templetEditController showWindow:sender];
}

- (IBAction)addClassFile:(id)sender
{
    NSInteger row = self.tableView.selectedRow;
    if (row >= 0) {
        self.classEditController = [[HCClassEditController alloc]initWithWindowNibName:@"HCClassEditController"];
        _classEditController.templetName = _listOfFiles[row];
        _classEditController.isEdit = NO;
        [self showVlassEditControllerWindow];
    }
}

- (void)showVlassEditControllerWindow
{
    __weak typeof(self) weakSelf = self;
    NSRect windowFrame = [[self window] frame];
    NSRect prefsFrame = [[_classEditController window] frame];
    prefsFrame.origin = NSMakePoint(windowFrame.origin.x + (windowFrame.size.width - prefsFrame.size.width) / 2.0,
                                    NSMaxY(windowFrame) - NSHeight(prefsFrame) - 20.0);
    
    _classEditController.saveBlock = ^(NSString *className){
        [weakSelf reloadFileWithTemplet];
    };
    [[_classEditController window] setFrame:prefsFrame display:NO];
    [_classEditController showWindow:_classEditController];
}

- (IBAction)removeClassFile:(id)sender
{
    if (self.fileTempletPlist.tempateType == HCTempateFileTypeCustom) {
        [_fileTempletPlist deleteClassFile:_collectionView.selectedClassFile path:self.fileTempletPlist.fileTemplatesPath];
    }
    else if (self.fileTempletPlist.tempateType == HCTempateFileTypeSystem) {
        NSString *language = self.fileTempletPlist.fileLanguage == HCFileLanguageTypeOC ? @"Objective-C" : @"Swift";
        [_fileTempletPlist deleteClassFile:_collectionView.selectedClassFile path:[NSString stringWithFormat:@"%@%@%@",self.fileTempletPlist.systempTempatePath,_fileTempletPlist.completionName,language]];
    }
    
    [self reloadFileWithTemplet];
}

#pragma mark - NSTableView Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _listOfFiles.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString *iden = [ tableColumn identifier ];
    if ([iden isEqualToString:@"ClassNameCell"]) {
        NSString *name = _listOfFiles[row];
        NSArray *nameArray = [_listOfFiles[row] componentsSeparatedByString:@"."];
        if (nameArray.count>0) {
            name = [nameArray firstObject];
            
        }
        NSTableCellView *cell = [ tableView makeViewWithIdentifier:@"ClassNameCell" owner:self ];
        if ([name isEqualToString:OCTitleName] || [name isEqualToString:SwiftTitleName]) {
            cell.textField.alignment = NSTextAlignmentCenter;
            cell.textField.font = [NSFont systemFontOfSize:15];
            cell.textField.textColor = [NSColor blackColor];
            name = [[name componentsSeparatedByString:@"ø"] firstObject];
        }else
        {
            cell.textField.alignment = NSTextAlignmentLeft;
            cell.textField.font = [NSFont systemFontOfSize:13];
            cell.textField.textColor = [NSColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
        }
        [cell.textField setStringValue:name];
        return cell;
    }
    return nil;
}

#pragma mark - NSTableView Delegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20;
}


#pragma mark - Getters & Setters
- (HCTempletManager *)fileTempletPlist
{
    if (!_fileTempletPlist) {
        _fileTempletPlist = [HCTempletManager sharedInstance];
    }
    return _fileTempletPlist;
}

@end
