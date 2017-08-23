//
//  HCTempletManager.h
//  HCTemplet
//
//  Created by Curry on 16/5/19.
//  Copyright © 2016年 curry. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FileManager [NSFileManager defaultManager]
#define OCTitleName @"Objective-CøOCStr"
#define SwiftTitleName @"SwiftøSWStr"

typedef NS_ENUM(NSUInteger, HCFileLanguageType) {
    HCFileLanguageTypeOC = 0,
    HCFileLanguageTypeSwift
};

typedef NS_ENUM(NSUInteger, HCTempateFileType) {
    HCTempateFileTypeSystem,
    HCTempateFileTypeCustom,
};


@interface HCTempletManager : NSObject
@property (nonatomic ,assign) HCFileLanguageType    fileLanguage;
@property (nonatomic ,assign) HCTempateFileType     tempateType;
@property (nonatomic ,copy) NSString*             completionName;     //plist Nmae
@property (nonatomic ,copy) NSString*             fileTemplatesPath;  //Templates path
@property (nonatomic ,copy) NSString*             xcpluginPath;       //plugin path
@property (nonatomic ,copy) NSString*             systempTempatePath; // xcode system tempate path

@property (nonatomic ,copy) NSString*             egClassHPath;       //objective c eg .h path
@property (nonatomic ,copy) NSString*             egClassMPath;       //objective c eg .m path
@property (nonatomic ,copy) NSString*             egClassSPath;       //swift c eg .swift path

@property (nonatomic ,strong) NSMutableDictionary* systemTemplatePlistData; // system Template data
@property (nonatomic ,strong) NSMutableArray*     systemClassValues; // system class array

+ (instancetype)sharedInstance;

// 运行shell脚本
+ (NSString *)runShellCommand:(NSString *)shell;
/**
 *  create Template xctemplate
 */
- (void)createTemplateInfoPlist;

/**
 *  save template info plist to hc xctemplate
 *
 *  @param templetDic info dic
 *         file path
 */
- (void)saveTemplateInfoPlistData:(NSDictionary *)templetDic path:(NSString *)filePath;

/**
 *  delete hc template
 *
 *  @param name template name
 */
- (void)deleteXCTemplateForName:(NSString *)name path:(NSString *)path;

/**
 *  get plugins keys
 *
 *  @return templetys key
 */
- (NSArray *)fileTempletsKeys;

/**
 *  get class file Name
 *
 *  @param templet templet name
 *  @param tempale path
 *  @return key list
 */
- (NSArray *)classFilesForTemplet:(NSString *)templet path:(NSString *)path;

/**
 *  get language icon image
 *
 *  @param className
 *
 *  @return image path
 */
- (NSString *)classFilePathImageWithName:(NSString *)className;

/**
 *  create class suffix name
 *
 *  @param name
 *  @param suffix
 *
 *  @return name
 */
- (NSString *)createClassName:(NSString *)name suffix:(NSString *)suffix;

/**
 *  save text file
 *
 *  @param className class name
 *  @param string    class text
 */
- (void)createClassFileWithPath:(NSString *)path name:(NSString *)className infoString:(NSString *)string;

/**
 *  delete Template for class file
 *
 *  @param fileName
 */
- (void)deleteClassFile:(NSString *)fileName path:(NSString *)path;

/**
 *  get templet info plist data
 *
 *  @param name templet name
 *
 *  @return plist info Dic
 */
- (NSMutableDictionary *)fileTempletInfoPlistWithName:(NSString *)name;
@end
