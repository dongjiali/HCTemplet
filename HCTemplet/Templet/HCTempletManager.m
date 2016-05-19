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
@property (nonatomic ,strong) NSBundle      *pluginsBundle;
@property (nonatomic ,strong) NSArray       *fileTemplets;
@property (nonatomic ,strong) NSString      *hcTemplatesDirPath;
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
    [self saveTemplateInfoPlistData:templetDic];
}

/**
 *  add template class file
 */
- (void)addTemplateClassAndImageList
{
    NSString *iconPath = [self.pluginsBundle pathForResource:OCStr ofType:@"png"];
    if (_fileLanguage == HCFileTypeOC) {
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
- (NSArray *)classFilesForTemplet:(NSString *)templet
{
    NSError *error = nil;
    self.completionName = templet;
    NSMutableArray *classList = [NSMutableArray arrayWithCapacity:1];
    NSArray *array = [FileManager contentsOfDirectoryAtPath:self.fileTemplatesPath  error:&error];
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
- (void)saveTemplateInfoPlistData:(NSDictionary *)templetDic
{
    NSString *hcFilePatch = self.fileTemplatesPath;
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
- (void)deleteXCTemplateForName:(NSString *)name
{
    self.completionName = name;
    NSString *hcFilePatch = self.fileTemplatesPath;
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
- (void)deleteClassFile:(NSString *)fileName
{
    NSString *hcFilePatch = [self.fileTemplatesPath stringByAppendingPathComponent:fileName];
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
- (void)createClassFileWithName:(NSString *)className infoString:(NSString *)string
{
    NSString *hcFilePatch = self.fileTemplatesPath;
    if ([FileManager fileExistsAtPath:hcFilePatch]) {
        [string writeToFile:[NSString stringWithFormat:@"%@/%@",hcFilePatch,className] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
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
    return self.fileLanguage==HCFileTypeOC?OCStr:SWStr;
}
@end
