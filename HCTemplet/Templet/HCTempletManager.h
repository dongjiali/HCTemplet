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
typedef enum HCFileLanguageType
{
    HCFileTypeOC = 0,
    HCFileTypeSwift
}HCFileLanguageType;

@interface HCTempletManager : NSObject
@property (nonatomic ,assign) HCFileLanguageType    fileLanguage;
@property (nonatomic ,strong) NSString*             completionName;     //plist Nmae
@property (nonatomic ,strong) NSString*             fileTemplatesPath;  //Templates path
@property (nonatomic ,strong) NSString*             xcpluginPath;       //plugin path

@property (nonatomic ,strong) NSString*             egClassHPath;       //objective c eg .h path
@property (nonatomic ,strong) NSString*             egClassMPath;       //objective c eg .m path
@property (nonatomic ,strong) NSString*             egClassSPath;       //swift c eg .swift path

+ (instancetype)sharedInstance;

/**
 *  create Template xctemplate
 */
- (void)createTemplateInfoPlist;

/**
 *  save template info plist to hc xctemplate
 *
 *  @param templetDic info dic
 */
- (void)saveTemplateInfoPlistData:(NSDictionary *)templetDic;

/**
 *  delete hc template
 *
 *  @param name template name
 */
- (void)deleteXCTemplateForName:(NSString *)name;

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
 *
 *  @return key list
 */
- (NSArray *)classFilesForTemplet:(NSString *)templet;

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
- (void)createClassFileWithName:(NSString *)className infoString:(NSString *)string;

/**
 *  delete Template for class file
 *
 *  @param fileName
 */
- (void)deleteClassFile:(NSString *)fileName;

/**
 *  get templet info plist data
 *
 *  @param name templet name
 *
 *  @return plist info Dic
 */
- (NSMutableDictionary *)fileTempletInfoPlistWithName:(NSString *)name;

@end
