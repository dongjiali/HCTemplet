//
//  HCTempletManager.m
//  HCTemplet
//
//  Created by Curry on 16/5/19.
//  Copyright © 2016年 curry. All rights reserved.
//

#import "HCTempletManager.h"

static NSString *OCStr = @"Objective-C";
static NSString *SWStr = @"Swift";

@interface HCTempletManager()
@property (nonatomic ,strong) NSBundle       *pluginsBundle;
@property (nonatomic ,copy) NSArray          *fileTemplets;
@property (nonatomic ,copy) NSString         *hcTemplatesDirPath;
@end

@implementation HCTempletManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static HCTempletManager * __singlManager__;
    dispatch_once( &once, ^{
        __singlManager__ = [[HCTempletManager alloc] init];
    });
    return __singlManager__;
}

- (void)createTemplateInfoPlist
{
    //create Tempplet path
    if (![FileManager fileExistsAtPath:self.fileTemplatesPath]) {
        [FileManager createDirectoryAtPath:self.fileTemplatesPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    //get plugins source data
    NSMutableDictionary *templetDic = [[NSMutableDictionary alloc]initWithContentsOfFile:self.xcpluginTemplatePath];
    //set @property
    templetDic[@"AllowedTypes"] = @[[NSString stringWithFormat:@"public.%@-source",[self fileLanguageByType]]];
    templetDic[@"DefaultCompletionName"] = _completionName?:@"FileTemplet";
    NSArray *options = templetDic[@"Options"];
    NSMutableDictionary *languageDic = options.lastObject;
    languageDic[@"Default"] = [self fileLanguageByType];
    [self addTemplateClassAndImageList];
    templetDic[@"MainTemplateFiles"] = _fileTemplets;
    [self saveTemplateInfoPlistData:templetDic path:self.fileTemplatesPath];
}

/**
 *  add template class file
 */
- (void)addTemplateClassAndImageList
{
    NSString *iconPath = [self.pluginsBundle pathForResource:OCStr ofType:@"png"];
    if (_fileLanguage == HCFileLanguageTypeOC) {
        //create objective-c file
        NSString *classNameH = [self createClassName:@"ViewController" suffix:@"h"];
        NSString *classNameM = [self createClassName:@"ViewController" suffix:@"m"];
        _fileTemplets = @[classNameH,classNameM];
        [self copyPluginsFileToTempletForPath:self.egClassHPath toFile:classNameH];
        [self copyPluginsFileToTempletForPath:self.egClassMPath toFile:classNameM];
    }else
    {
        //create swift file
        NSString *classNameSwift = [self createClassName:@"ViewController" suffix:@"swift"];
        _fileTemplets = @[classNameSwift];
        [self copyPluginsFileToTempletForPath:self.egClassSPath toFile:classNameSwift];
        iconPath = [self.pluginsBundle pathForResource:SWStr ofType:@"png"];
    }
    [self copyPluginsFileToTempletForPath:iconPath toFile:@"TemplateIcon.png"];
}

/**
 *  get plugins keys
 *
 *  @return templetys key
 */
- (NSArray *)fileTempletsKeys
{
    NSError *error = nil;
    NSMutableArray *fileList = [NSMutableArray array];
    NSMutableArray *ocFleList = [NSMutableArray array];
    NSMutableArray *swFileList = [NSMutableArray array];
    
    NSArray *array = [FileManager contentsOfDirectoryAtPath:self.hcTemplatesDirPath error:&error];
    for (NSString *key in array) {
        if ([key hasSuffix:@".xctemplate"]) {
            NSString *name = [[key componentsSeparatedByString:@"."] firstObject];
            NSDictionary *templetDic = [self fileTempletInfoPlistWithName:name];
            NSArray *options = templetDic[@"Options"];
            NSDictionary *languageDic = options.lastObject;
            if ([languageDic[@"Default"] isEqualToString:OCStr]) {
                [ocFleList addObject:name];
            }else if ([languageDic[@"Default"] isEqualToString:SWStr]){
                [swFileList addObject:name];
            }
        }
    }
    if (ocFleList.count>0) {
        [fileList addObject:OCTitleName];
        [fileList addObjectsFromArray:ocFleList];
    }
    if (swFileList.count>0) {
        [fileList addObject:SwiftTitleName];
        [fileList addObjectsFromArray:swFileList];
    }
    return fileList;
}
/**
 *  get class file Name
 *
 *  @param templet templet name
 *
 *  @return key list
 */
- (NSArray *)classFilesForTemplet:(NSString *)templet path:(NSString *)path
{
    NSError *error = nil;
    self.completionName = templet;
    NSMutableArray *classList = [NSMutableArray array];
    NSArray *array = [FileManager contentsOfDirectoryAtPath:path  error:&error];
    for (NSString *key in array) {
        if ([key hasPrefix:@"___FILEBASENAME___"]) {
            [classList addObject:key];
        }
    }
    return classList;
}

/**
 *  get templet info plist data
 *
 *  @param name templet name
 *
 *  @return plist info Dic
 */
- (NSMutableDictionary *)fileTempletInfoPlistWithName:(NSString *)name
{
    self.completionName = name;
    NSString *selfPath = self.fileTemplatesPath;
    NSBundle *selfBundle = [NSBundle bundleWithPath:[selfPath stringByExpandingTildeInPath]];
    NSString *templateInfo_file = [selfBundle pathForResource:@"TemplateInfo" ofType:@"plist"];
    return [[NSMutableDictionary alloc]initWithContentsOfFile:templateInfo_file];
}

/**
 *  save template info plist
 *
 *  @param templetDic info dic
 */
- (void)saveTemplateInfoPlistData:(NSDictionary *)templetDic path:(NSString *)filePath
{
    NSString *hcFilePatch = filePath;
    NSString *filename =[hcFilePatch stringByAppendingPathComponent:@"TemplateInfo.plist"];
    if ([FileManager fileExistsAtPath:hcFilePatch]) {
        [templetDic writeToFile:filename atomically:YES];
    };
}

/**
 *  delete Template
 *
 *  @param name template name
 */
- (void)deleteXCTemplateForName:(NSString *)name path:(NSString *)path
{
    self.completionName = name;
    NSString *hcFilePatch = path;
    if ([FileManager fileExistsAtPath:hcFilePatch]) {
        NSError *err;
        [FileManager removeItemAtPath:hcFilePatch error:&err];
        self.completionName = @"";
    }
}
/**
 *  delete Template for class file
 *
 *  @param fileName
 */
- (void)deleteClassFile:(NSString *)fileName path:(NSString *)path
{
    NSString *hcFilePatch = [path stringByAppendingPathComponent:fileName];
    if ([FileManager fileExistsAtPath:hcFilePatch]) {
        NSError *err;
        [FileManager removeItemAtPath:hcFilePatch error:&err];
    }
}

/**
 *  save text file
 *
 *  @param className class name
 *  @param string    class text
 */
- (void)createClassFileWithPath:(NSString *)path name:(NSString *)className infoString:(NSString *)string
{
    NSString *hcFilePatch = path;
    if ([FileManager fileExistsAtPath:hcFilePatch]) {
        NSError *error = nil;
        [string writeToFile:[NSString stringWithFormat:@"%@/%@",hcFilePatch,className] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    };
}

/**
 *  get language icon image
 *
 *  @param className
 *
 *  @return image path
 */
- (NSString *)classFilePathImageWithName:(NSString *)className
{
    NSString *resourcePath = nil;
    
    if ([className hasSuffix:@".h"]) {
        resourcePath = [self.pluginsBundle pathForResource:@"Objective-C-h" ofType:@"png"];
    }else if ([className hasSuffix:@".m"]){
        resourcePath = [self.pluginsBundle pathForResource:@"Objective-C-m" ofType:@"png"];
    }else if ([className hasSuffix:@".swift"]){
        resourcePath = [self.pluginsBundle pathForResource:@"Swift" ofType:@"png"];
    }
    return resourcePath;
}

/**
 *  copy class templet txt to plugins
 *
 *  @param name file Name
 */
- (void)copyPluginsFileToTempletForPath:(NSString *)srcPath toFile:(NSString *)fileName
{
    NSError *error = nil;
    if ([FileManager fileExistsAtPath:self.fileTemplatesPath]) {
        [FileManager copyItemAtPath:srcPath toPath:[NSString stringWithFormat:@"%@/%@",self.fileTemplatesPath,fileName] error:&error];
    }
}

- (NSMutableDictionary *)systemTemplatePlistData {
    NSString *resourcePath = [[NSBundle mainBundle] bundlePath];
    NSString *sysXcodeTemplatePlistPath = [self.systempTempatePath stringByAppendingString:@"TemplateInfo.plist"];
    NSMutableDictionary *templetDic = [[NSMutableDictionary alloc]initWithContentsOfFile:sysXcodeTemplatePlistPath];
    NSLog(@"%@",resourcePath);
    return templetDic;
}

- (NSMutableArray *)systemClassValues {
    NSArray *optionArray = self.systemTemplatePlistData[@"Options"];
    NSMutableArray *valueArray = nil;
    for (NSDictionary *dic in optionArray) {
        for (NSString *key in dic.allKeys) {
            if ([key isEqualToString:@"Identifier"] &&
                [dic[@"Identifier"] isEqualToString:@"cocoaTouchSubclass"]) {
                valueArray = dic[@"Values"];
            }
        }
    }
    return valueArray;
}

/**
 *  create class suffix name
 *
 *  @param name
 *  @param suffix
 *
 *  @return name
 */
- (NSString *)createClassName:(NSString *)name suffix:(NSString *)suffix
{
    return [NSString stringWithFormat:@"___FILEBASENAME___%@.%@",name,suffix];
}

#pragma mark - Getters & Setters

- (NSBundle *)pluginsBundle
{
    if (!_pluginsBundle) {
        _pluginsBundle = [NSBundle bundleWithPath:[self.xcpluginPath stringByExpandingTildeInPath]];
    }
    return _pluginsBundle;
}

- (NSString *)egClassHPath
{
    if (!_egClassHPath) {
        _egClassHPath = [self.pluginsBundle pathForResource:@"VC_H" ofType:@"txt"];
    }
    return _egClassHPath;
}

- (NSString *)egClassMPath
{
    if (!_egClassMPath) {
        _egClassMPath = [self.pluginsBundle pathForResource:@"VC_M" ofType:@"txt"];
    }
    return _egClassMPath;
}

- (NSString *)egClassSPath
{
    if (!_egClassSPath) {
        _egClassSPath = [self.pluginsBundle pathForResource:@"VC_S" ofType:@"txt"];
    }
    return _egClassSPath;
}

- (NSString *)hcTemplatesDirPath
{
    if (!_hcTemplatesDirPath) {
        NSString *fileTemplates =[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        _hcTemplatesDirPath = [fileTemplates stringByAppendingString:@"/Developer/Xcode/Templates/File Templates/HC Templates"];
        
    }
    return _hcTemplatesDirPath;
}

/**
 *  TemplatesPath
 *
 */
- (NSString *)fileTemplatesPath
{
    return [NSString stringWithFormat:@"%@/%@.xctemplate",self.hcTemplatesDirPath,self.completionName];
}

/**
 *  xcpluginPath
 *
 */
- (NSString *)xcpluginPath
{
    if (!_xcpluginPath) {
        NSString *pluginPath =[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        _xcpluginPath = [pluginPath stringByAppendingString:@"/Application Support/Developer/Shared/Xcode/Plug-ins/HCTemplet.xcplugin"];
    }
    return _xcpluginPath;
}

/**
 *  system tempate Path
 *
 */
- (NSString *)systempTempatePath
{
    if (!_systempTempatePath) {
        NSString *resourcePath = [[NSBundle mainBundle] bundlePath];
        NSString *templateInfoPlistPath = @"/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/File Templates/Source/Cocoa Touch Class.xctemplate/";
        _systempTempatePath = [resourcePath stringByAppendingString:templateInfoPlistPath];
        
        // 检查权限
        NSString *userName = [[HCTempletManager runShellCommand:@"echo $USER"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *path = [_systempTempatePath stringByReplacingOccurrencesOfString:@" " withString:@"' '"];
        
        NSString *folderPermission = [HCTempletManager runShellCommand:[NSString stringWithFormat:@"ls -l %@",path]];
        
        if (![folderPermission containsString:userName]) {
            // 给文件夹添加权限
            NSString *script = [NSString stringWithFormat:@"do shell script \"chown -R %@ %@\" with administrator privileges", userName, path];
            NSDictionary *errorDict = nil;
            NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
            if ([appleScript executeAndReturnError:&errorDict]) {
                NSLog(@"execcute success");
            } else {
                NSLog(@"%@",[NSString stringWithFormat:@"execute failure : %@", errorDict]);
            }
        }
    }
    return _systempTempatePath;
}

/**
 *  TemplateInfo.plist path
 *
 */
- (NSString *)xcpluginTemplatePath
{
    NSString *templateInfo_file = [self.pluginsBundle pathForResource:@"TemplateInfo" ofType:@"plist"];
    return templateInfo_file;
}

- (NSString *)fileLanguageByType
{
    return self.fileLanguage == HCFileLanguageTypeOC ? OCStr : SWStr;
}

+ (NSString *)runShellCommand:(NSString *)shell {
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", [NSString stringWithFormat:@"%@", shell]]];
    [task setStandardOutput:pipe];
    NSFileHandle* file = [pipe fileHandleForReading];
    [task launch];
    return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}
@end

