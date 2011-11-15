//
//  DownloadItemCell.m
//  Download
//
//  Created by  on 11-11-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DownloadItemCell.h"
#import "DownloadItem.h"
#import "LocaleUtils.h"

@implementation DownloadItemCell
@synthesize starButton;
@synthesize webSiteLabel;
@synthesize pauseButton;
@synthesize fileTypeLabel;
@synthesize fileNameLabel;
@synthesize statusLabel;
@synthesize downloadProgress;
@synthesize downloadDetailLabel;

- (void)setCellStyle
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;		   
}

- (void)awakeFromNib{
    [self setCellStyle];
}

// just replace ProductDetailCell by the new Cell Class Name
+ (DownloadItemCell*) createCell:(id)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DownloadItemCell" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <DownloadItemCell> but cannot find cell object from Nib");
        return nil;
    }
    
    ((DownloadItemCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return (DownloadItemCell*)[topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"DownloadItemCell";
}

+ (CGFloat)getCellHeight
{
    return 106.0f;
}

#define SIZE_ONE_MB (1000000.0)
#define SIZE_ONE_KB (1000.0)

- (NSString*)getSizeInfo:(DownloadItem*)item
{
    double downloadSize = [item.downloadSize doubleValue];
    double totalSize = [item.fileSize doubleValue];    
    
    if ([item.status intValue] == DOWNLOAD_STATUS_FINISH){                
        if (totalSize >= SIZE_ONE_MB || downloadSize >= SIZE_ONE_MB){
            return [NSString stringWithFormat:@"%.2f MB", totalSize/SIZE_ONE_MB];
        }
        else{
            return [NSString stringWithFormat:@"%.2f KB", totalSize/SIZE_ONE_KB];        
        }            
    }
    else{
        if (totalSize >= SIZE_ONE_MB || downloadSize >= SIZE_ONE_MB){
            return [NSString stringWithFormat:@"%.2f/%.2f MB", downloadSize/SIZE_ONE_MB, totalSize/SIZE_ONE_MB];
        }
        else{
            return [NSString stringWithFormat:@"%.2f/%.2f KB", downloadSize/SIZE_ONE_KB, totalSize/SIZE_ONE_KB];        
        }    
    }
}

- (NSString*)getPercentageInfo:(DownloadItem*)item
{
    double downloadSize = [item.downloadSize doubleValue];
    double totalSize = [item.fileSize doubleValue];    

    if ([item.status intValue] == DOWNLOAD_STATUS_FINISH){
        return @"";
    }
    
    if (totalSize > 0.0f){
        return [NSString stringWithFormat:@"%d%%", (int)((downloadSize/totalSize)*100)]; 
    }
    else{
        return @"";
    }
}

- (NSString*)getLeftInfo:(DownloadItem*)item
{
    return @""; // TODO
}

- (void)setPauseButtonInfo:(DownloadItem*)item
{
    [self.pauseButton setHidden:NO];
    if ([item canPause]){
        [self.pauseButton setTitle:NSLS(@"Pause") forState:UIControlStateNormal];
    }
    else if ([item canResume]){
        [self.pauseButton setTitle:NSLS(@"Resume") forState:UIControlStateNormal];
    }
    else if ([item canPlay]){
        if ([item isAudioVideo]){
            [self.pauseButton setTitle:NSLS(@"Play") forState:UIControlStateNormal];        
        }
        else if ([item canView]){
            [self.pauseButton setTitle:NSLS(@"View") forState:UIControlStateNormal];        
        }
        else{
            [self.pauseButton setTitle:@"" forState:UIControlStateNormal];
            [self.pauseButton setHidden:YES];            
        }
    }             
    else{
        [self.pauseButton setTitle:@"" forState:UIControlStateNormal];
        [self.pauseButton setHidden:YES];
    }
}

- (void)setCellInfoWithItem:(DownloadItem*)item indexPath:(NSIndexPath*)indexPath
{
    self.fileTypeLabel.text = [item.fileName pathExtension];
    self.fileNameLabel.text = item.fileName;
    self.statusLabel.text = [item statusText];
    
    NSString* sizeInfo = [self getSizeInfo:item];
    NSString* percentageInfo = [self getPercentageInfo:item];
    NSString* leftInfo = [self getLeftInfo:item];    
    self.downloadDetailLabel.text = [NSString stringWithFormat:@"%@ %@ %@", sizeInfo, percentageInfo, leftInfo];
    self.downloadProgress.progress = [item.downloadProgress floatValue];
    
    self.webSiteLabel.text = [NSString stringWithFormat:NSLS(@"kFromWebSite"), item.webSite];
    
    [self setPauseButtonInfo:item];
    
    if ([item canPlay]){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else{
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (IBAction)clickPause:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(clickPause:atIndexPath:)])
        [delegate clickPause:sender atIndexPath:self.indexPath];
}

- (IBAction)clickStar:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(clickPause:atIndexPath:)])
        [delegate clickStar:sender atIndexPath:self.indexPath];    
}

- (void)dealloc {
    [fileTypeLabel release];
    [fileNameLabel release];
    [statusLabel release];
    [downloadDetailLabel release];
    [downloadProgress release];
    [pauseButton release];
    [starButton release];
    [webSiteLabel release];
    [super dealloc];
}
@end
