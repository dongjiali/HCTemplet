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
@property (nonatomic, weak) IBOutlet HCFilesCollectionView  *collectionView;
@property (nonatomic, weak) IBOutlet NSSearchField          *searchField;

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
    [self reloadDataWithFilter:nil];
    [self.tableView reloadData];
    
    [self classFileEditControllerBlock];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method
- (void)reloadDataWithFilter:(NSString *)filter {
    _listOfFiles = [[NSMutableArray alloc]initWithArray:[self.fileTempletPlist fileTempletsKeys]];
    _classFiles = [[NSMutableArray alloc]initWithCapacity:1];
    for (NSString *key in _listOfFiles) {
        NSMutableArray *classFiles = [[NSMutableArray alloc]initWithArray:[self.fileTempletPlist classFilesForTemplet:key]];
        [_classFiles addObject:classFiles];
    }
}

- (void)reloadFileWithTemplet
{
    [self reloadDataWithFilter:nil];
    NSInteger row = _tableView.selectedRow;
    if (row >= 0) {
        _collectionView.classFileList = _classFiles.count?_classFiles[row]:nil;
    }
}

- (void)classFileEditControllerBlock
{
    __weak typeof(self) weakSelf = self;
    self.collectionView.editBlock = ^(NSString *className)
    {
        NSInteger row = self.tableView.selectedRow;
        if (row >= 0) {
            weakSelf.classEditController = [[HCClassEditController alloc]initWithWindowNibName:@"HCClassEditController"];
            weakSelf.classEditController.templetName = weakSelf.listOfFiles[row];
            weakSelf.classEditController.isEdit = YES;
            weakSelf.classEditController.className = className;
            [weakSelf showVlassEditControllerWindow];
        }
    };
}

- (void)changeClassViewStatusByClassLists:(NSArray *)list
{
    _classInfoLabel.hidden = !list.count;
    _addCalssBtn.hidden = !list.count;
    _removeClassBtn.hidden = !list.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView =notification.object;
    NSInteger row = tableView.selectedRow;
    if (row >= 0) {
        _fileTempletPlist.completionName = self.listOfFiles[row];
        self.collectionView.classFileList = self.classFiles[row];
        [self changeClassViewStatusByClassLists:self.classFiles[row]];
    }
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
                              NSString *templetString = _listOfFiles[row];
                              [weakSelf.fileTempletPlist deleteXCTemplateForName:templetString];
                              [weakSelf reloadFileWithTemplet];
                              [weakSelf.tableView reloadData];
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
        [weakSelf reloadDataWithFilter:nil];
        [weakSelf.tableView reloadData];
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
    [_fileTempletPlist deleteClassFile:_collectionView.selectedClassFile];
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
        [cell.textField setStringValue:name];
        if ([name isEqualToString:@"Objective-C"] || [name isEqualToString:@"Swift"]) {
            cell.textField.alignment = NSTextAlignmentCenter;
            cell.textField.font = [NSFont systemFontOfSize:15];
            cell.textField.textColor = [NSColor blackColor];
        }else
        {
            cell.textField.alignment = NSTextAlignmentLeft;
            cell.textField.font = [NSFont systemFontOfSize:13];
            cell.textField.textColor = [NSColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1];
        }
        
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
