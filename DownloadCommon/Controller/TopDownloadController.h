//
//  TopDownloadController.h
//  Download
//
//  Created by  on 11-11-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "ResourceService.h"

@class TopDownloadItem;
@class TopDownloadItemCell;

@interface TopDownloadController : PPTableViewController <ResourceServiceDelegate, UIActionSheetDelegate> {
    int requestType;
    int startOffset;
    NSMutableArray* toplist;
    TopDownloadItem* currentSelectItem;
}

@property (nonatomic, assign) int requestType;
@property (nonatomic, assign) int startOffset;
@property (nonatomic, retain) NSMutableArray* toplist;
@property (nonatomic, retain) TopDownloadItem* currentSelectItem;
@property (nonatomic, retain) TopDownloadItemCell* lastSelectedCell;
- (void)askDownload;
- (void) hasDownloaded:(TopDownloadItem*) downloadItem;
- (UIColor*)getDefaultTextColor;
@end
