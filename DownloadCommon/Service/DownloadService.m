//
//  DownloadService.m
//  Download
//
//  Created by  on 11-11-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DownloadService.h"
#import "ASIHTTPRequest.h"
#import "LogUtil.h"
#import "FileUtil.h"
#import "DownloadItem.h"
#import "TopDownloadItem.h"
#import "DownloadItemManager.h"
#import "UIUtils.h"
#import "StringUtil.h"
#import "StatusView.h"
#import "LocaleUtils.h"
#import "DownloadNetworkRequest.h"
#import "DownloadNetworkConstants.h"
#import "PPNetworkRequest.h"

#import "PlayAudioVideoController.h"
#import "DisplayReadableFileController.h"
#import "CommonFileActionController.h"

#define DOWNLOAD_DIR                @"/download/incoming/"
#define DOWNLOAD_TEMP_DIR           @"/download/temp/"
#define DOWNLOAD_ICLOUD_DIR           @"/download/iCloud/"

DownloadService* globalDownloadService;

@implementation DownloadService

@synthesize queue;
@synthesize downloadDir;
@synthesize downloadTempDir;
@synthesize concurrentDownload;
@synthesize videoPlayController;
@synthesize fileViewController;
@synthesize iCloudDir;

- (void)dealloc
{
    [downloadDir release];
    [iCloudDir release];
    [downloadTempDir release];
    [videoPlayController release];
    [queue release];
    [super dealloc];
}

- (id)init
{
    self = [super init];

    self.downloadDir = [[FileUtil getAppHomeDir] stringByAppendingFormat:DOWNLOAD_DIR];
    self.downloadTempDir = [[FileUtil getAppHomeDir] stringByAppendingFormat:DOWNLOAD_TEMP_DIR];   
    self.iCloudDir = [[FileUtil getAppHomeDir] stringByAppendingFormat:DOWNLOAD_ICLOUD_DIR];
    self.concurrentDownload = 20;  

    // create queue
    [self setQueue:[[[NSOperationQueue alloc] init] autorelease]];
    [self.queue setMaxConcurrentOperationCount:self.concurrentDownload];
    
    // create directory if not exist
    [FileUtil createDir:self.downloadTempDir];
    [FileUtil createDir:self.downloadDir];    
    [FileUtil createDir:self.iCloudDir];
    
    self.videoPlayController = [[[PlayAudioVideoController alloc] init] autorelease];    
    self.fileViewController = [[[DisplayReadableFileController alloc] init] autorelease];
    return self;
}

+ (DownloadService*)defaultService
{
    if (globalDownloadService == nil){
        globalDownloadService = [[DownloadService alloc] init];
        
    }
    
    return globalDownloadService;
}

#pragma File Creation and Generation

- (NSString*)createFileName:(NSString*)lastPathComponent
{
    DownloadItemManager* manager = [DownloadItemManager defaultManager];
    
    NSString* lastPath = lastPathComponent;
    NSString* pathExtension = [lastPath pathExtension];
    NSString* pathWithoutExtension = [lastPath stringByDeletingPathExtension];
    
    BOOL foundName = NO;    
    int i = 0;
    while (!foundName){
        if ([manager findItemByName:lastPath] != nil){            
            i ++;
            lastPath = [pathWithoutExtension stringByAppendingFormat:@"(%d).%@", i, pathExtension];
        }
        else{
            foundName = YES;
        }
    }
    
    return lastPath;
}

- (NSString*)getFilePath:(NSString*)fileName
{
    return [self.downloadDir stringByAppendingString:fileName];
}

- (NSString*)getTempFilePath:(NSString*)fileName
{
    return [self.downloadTempDir stringByAppendingString:fileName];
}

#pragma Download Internal Methods

- (BOOL)startDownload:(DownloadItem*)item
{
    NSURL* url = [NSURL URLWithString:[item url]];
    
    // start to download
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [[DownloadItemManager defaultManager] downloadStart:item request:request];
    
    [request setDownloadDestinationPath:[item localPath]];    
    [request setAllowResumeForFileDownloads:YES];
    [request setTemporaryFileDownloadPath:[item tempPath]];    
    [request setUserInfo:[item dictionaryForRequest]];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:item];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [request setResponseEncoding:NSUTF8StringEncoding];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];

    PPDebug(@"download file, URL=%@, save to %@, temp path %@", [item url], [item localPath], [item tempPath]);

    [[self queue] addOperation:request];
    return YES;
}

#pragma External Methods

- (BOOL)downloadFile:(NSString*)urlString fileType:(int)fileType webSite:(NSString*)webSite webSiteName:(NSString*)webSiteName origUrl:(NSString*)origUrl
{                
    NSURL* url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url] == NO){
        PPDebug(@"downloadFile but cannot open URL = %@", urlString);
        return NO;
    }
    
    NSString* fileName = [NSString GetUUID]; // [self createFileName:url];
    NSString* filePath = [self getFilePath:fileName];
    NSString* tempFilePath = [self getTempFilePath:fileName];
    
    // save download item
    DownloadItemManager* downloadItemManager = [DownloadItemManager defaultManager];
    DownloadItem* downloadItem = [downloadItemManager createDownloadItem:urlString 
                                                                fileType:fileType
                                                                 webSite:webSite 
                                                             webSiteName:webSiteName 
                                                                 origUrl:origUrl
                                                                fileName:@""            // no file name
                                                                filePath:filePath                                  
                                                                tempPath:tempFilePath];
    
    [self startDownload:downloadItem];    
    return YES;
}

#pragma Item Play/Pause/Resume

- (UIViewController<CommonFileActionProtocol>*)getViewControllerByItem:(DownloadItem*)downloadItem
{
    if ([downloadItem isAudioVideo]){
        return videoPlayController;
    }
    else if ([downloadItem isReadableFile]){
        return fileViewController;
    }
    else{
        return [[[DisplayReadableFileController alloc] initWithDownloadItem:downloadItem] autorelease];
    }
    return nil;
}

- (void)pauseDownloadItem:(DownloadItem*)item
{
    [[item request] clearDelegatesAndCancel];
    [[DownloadItemManager defaultManager] downloadPause:item];
}

- (void)resumeDownloadItem:(DownloadItem*)item
{
    [self startDownload:item];
}

- (void)playItem:(DownloadItem*)item viewController:(UIViewController*)viewController
{
    UIViewController<CommonFileActionProtocol>* playController = [self getViewControllerByItem:item];
    [playController preview:viewController downloadItem:item];
}

- (void)pauseAllDownloadItem
{
    DownloadItemManager* manager = [DownloadItemManager defaultManager];
    NSArray* array = [manager findAllItemsByStatus:DOWNLOAD_STATUS_STARTED];
    for (DownloadItem* item in array){
        [self pauseDownloadItem:item];
    }
}

- (void)reportDownload:(DownloadItem*)item
{
    if ([[DownloadItemManager defaultManager] isURLReport:item.url]){
        return;
    }
    
    NSString* appId = @"";
    
    dispatch_async(workingQueue, ^{
        
        // fetch user place data from server
        CommonNetworkOutput* output = nil;        
        output = [DownloadNetworkRequest reportDownload:SERVER_URL 
                                                  appId:appId 
                                               fileType:[item.fileName pathExtension]
                                               fileName:item.fileName
                                                    url:item.url
                                                webSite:item.webSite
                                            webSiteName:item.webSiteName
                                               fileSize:[item.fileSize longValue]
                                            countryCode:[LocaleUtils getCountryCode]
                                               language:[LocaleUtils getLanguageCode]];
        
        // if succeed, clean local data and save new data
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // save data locally
            if (output.resultCode == 0){
                [[DownloadItemManager defaultManager] setURLReported:item.url];
            }            
        });                
    });    
}

#pragma ASIHTTPRequest Delegate

- (NSString*)unicodeStringToUTF8:(NSString*)unicodeString
{
    NSData* data = [unicodeString dataUsingEncoding:NSUnicodeStringEncoding];
    NSData* data1 = [unicodeString dataUsingEncoding:NSISOLatin1StringEncoding];
    
    NSString* str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSString* str1 = [[NSString alloc] initWithBytes:[data1 bytes] length:[data1 length] encoding:NSUTF8StringEncoding];
        
    NSLog(@"unicodeString=%@, str=%@, str1=%@", unicodeString, str, str1);
    
//    return finalString;
    return nil;
}

- (NSString *)replaceUnicode:(NSString *)yourString {  
    
    int i = 0;
    int len = [yourString length];    
    char* charArray = malloc(sizeof(char)*(len+1));
    for (i=0; i<len; i++){
        unichar ch = [yourString characterAtIndex:i];
        charArray[i] = ch;
//        NSLog(@"char = %02x, %d, %c", ch, ch, ch);
    }
    charArray[i] = '\0';
    
    NSString* str = [[[NSString alloc] initWithUTF8String:charArray] autorelease];    
    if (str == nil){
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        str = [NSString stringWithCString:charArray encoding:enc];
    }    
    return str;
}

- (NSString*)getFileNameFromContentDisposition:(NSString*)data
{
    if (data == nil)
        return nil;
                
    NSString* retStr = [self replaceUnicode:data];    
    retStr = [retStr stringByReplacingOccurrencesOfString:@"attachment;" withString:@""];    
    retStr = [retStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    retStr = [retStr stringByReplacingOccurrencesOfString:@"filename=" withString:@""];
    retStr = [retStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];

    PPDebug(@"Content Disposition = %@, %@", data, retStr);        
    return retStr;
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    DownloadItem *item = [DownloadItem fromDictionary:request.userInfo];
    PPDebug(@"item (%@) requestStarted, url = %@", [item itemId], [item.url description]);        
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    DownloadItemManager *manager = [DownloadItemManager defaultManager];
    DownloadItem *item = [DownloadItem fromDictionary:request.userInfo];        
    
    // rename item here
    NSString* fileName1 = [self getFileNameFromContentDisposition:[responseHeaders valueForKey:@"Content-Disposition"]];
    NSString* fileName2 = [responseHeaders objectForKey:@"Content-Location"];
    
    PPDebug(@"item (%@) didReceiveResponseHeaders Content-Disposition = %@, Content-Location = %@", [item itemId], fileName1, fileName2);    
    
    NSString* fileName = nil;
    if (fileName1 != nil){
        fileName = [fileName1 lastPathComponent];    
    }
    else if (fileName2 != nil){
        fileName = [fileName2 lastPathComponent];
    }
    else{
        fileName = [[request url] lastPathComponent];
    }
    
    // TODO
    if (fileName == nil){
        PPDebug(@"<didReceiveResponseHeaders> Cannot create file name for download request (%@)", [request description]);
        [request clearDelegatesAndCancel];
        [self requestWentWrong:request];
        return;
    }
    
    fileName = [manager adjustImageFileName:item newFileName:fileName];
    fileName = [self createFileName:fileName];
    
    long fileSize = [[responseHeaders valueForKey:@"Content-Length"] intValue];

    // set right file name here
    [manager setFileInfo:item newFileName:fileName fileSize:fileSize];
    
    // notify UI to show info
    NSString* statusText = [NSString stringWithFormat:NSLS(@"kDownloadStart"), item.fileName];
    [StatusView showtStatusText:statusText vibrate:NO duration:10.0];
    
    // report to server
    [self reportDownload:item];
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    DownloadItem *item = [DownloadItem fromDictionary:request.userInfo];
    PPDebug(@"item (%@) willRedirectToURL = %@", [item itemId], [newURL description]);    
}

- (void)requestRedirected:(ASIHTTPRequest *)request
{
    DownloadItem *item = [DownloadItem fromDictionary:request.userInfo];
    PPDebug(@"item (%@) requestRedirected", [item itemId]);        
}

- (void)moveFile:(DownloadItem*)item
{
    NSString* finalFilePath = [self getFilePath:item.fileName];
    NSError* error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:item.localPath toPath:finalFilePath error:&error];
    if (error != nil){
        NSLog(@"fail to rename file from %@ to %@", item.localPath, finalFilePath);
    }
    else{
        [item setLocalPath:finalFilePath];
    }
}

- (void)requestDone:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    DownloadItem *item = [DownloadItem fromDictionary:request.userInfo];
    [self moveFile:item];
    [[DownloadItemManager defaultManager] finishDownload:item];
    PPDebug(@"item (%@) download done, response done = %@", [item itemId], response);
    
    NSString* statusText = [NSString stringWithFormat:NSLS(@"kDownloadFinish"), item.fileName];
    [StatusView showtStatusText:statusText vibrate:NO duration:10.0];
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    DownloadItem *item = [DownloadItem fromDictionary:request.userInfo];
    [[DownloadItemManager defaultManager] downloadFailure:item];
    PPDebug(@"item (%@) download failure, response done = %@", [item itemId], [error description]);
    
    NSString* fileInfo = ([item.fileName length] > 0) ? item.fileName : item.url;
    NSString* statusText = [NSString stringWithFormat:NSLS(@"kDownloadFailure"), fileInfo];
    [StatusView showtStatusText:statusText vibrate:NO duration:10.0];

}

- (BOOL)hasDownloaded:(TopDownloadItem*)topItem
{
    DownloadItemManager* downloadManager = [DownloadItemManager defaultManager];
    DownloadItem *item = [downloadManager findItemByUrl:topItem.url];
    if (item == nil) {
        return NO;
    } 
    return YES;
    
}
@end
