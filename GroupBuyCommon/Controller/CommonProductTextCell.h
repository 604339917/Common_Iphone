//
//  CommonProductTextCell.h
//  groupbuy
//
//  Created by  on 11-11-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PPTableViewCell;
@class Product;

enum PRODUCT_DISPLAY_TYPE{
    
    PRODUCT_DISPLAY_GROUPBUY,
    PRODUCT_DISPLAY_TAOBAO,
    PRODUCT_DISPLAY_AD,
};

@protocol CommonProductTextCell <NSObject>

+ (PPTableViewCell<CommonProductTextCell>*)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
+ (BOOL)needReloadVisiableCellTimer;

- (void)setCellInfoWithProduct:(Product*)product indexPath:(NSIndexPath*)indexPath;
- (void)setCellInfoWithProductDictionary:(NSDictionary*)product indexPath:(NSIndexPath*)indexPath;

@end
