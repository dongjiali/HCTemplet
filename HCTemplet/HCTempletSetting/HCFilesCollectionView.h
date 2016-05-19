//
//  HCFilesCollectionView.h
//  HCTemplet
//
//  Created by Curry on 16/5/17.
//  Copyright © 2016年 curry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^edit_class_file_block)(NSString *className);

@interface HCFilesCollectionView : NSCollectionView
@property (nonatomic, copy) edit_class_file_block editBlock;
@property (nonatomic , strong) NSArray      *classFileList;
@property (nonatomic , strong) NSString     *selectedClassFile;
@end


@interface HCCollectionItem : NSCollectionViewItem
@end

@interface HCView : NSView
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,strong) NSString       *title;
@property (nonatomic,strong) NSString       *imagePath;
@end