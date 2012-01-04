//
//  BookController.m
//  Download
//
//  Created by gckj on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BookController.h"
#import "DownloadResource.h"
#import "DownloadItemManager.h"
#import "DownloadItem.h"

@implementation BookController

@synthesize currentIndex;
@synthesize tipsLabel;
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [tipsLabel release];
    [webView release];
}

- (void)showTips:(NSString *)text
{ 
    if (self.tipsLabel == nil) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 320, 40)];
        [label setFont:[UIFont systemFontOfSize:14]];
        self.tipsLabel = label;
        [label release];
        [self.tipsLabel setTextAlignment:UITextAlignmentCenter];
        [self.view addSubview:self.tipsLabel];
        [self.tipsLabel setBackgroundColor:[UIColor clearColor]];
        [self.tipsLabel setTextColor:BUTTON_TEXT_NORMAL_COLOR];
        
    }
    [self.tipsLabel setText:text];
    [self.tipsLabel setHidden:NO];
}

- (void)hideTips
{
    [self.tipsLabel setHidden:YES];
}

- (void)updateNavigationTitle:(NSString*)titleString
{
    UILabel* label = (UILabel *)self.navigationItem.titleView;
    label.text = titleString;
}

- (NSArray*)findAllRelatedItems
{
    return [[DownloadItemManager defaultManager] findAllReadableItems];
}

- (void)showBook:(int)indexValue
{
    if (indexValue >= 0) {
        currentIndex = indexValue;
    }
    
    NSArray *itemList = [self findAllRelatedItems];
    
    if ([itemList count] == 0) {
        [self showTips:NSLS(@"kNoBook")];
        return;
    }
    
    if (webView == nil) {
        self.view.frame = self.view.bounds;
        CGRect frame = [self.view bounds];
        webView = [[UIWebView alloc]initWithFrame:frame];
        webView.multipleTouchEnabled = YES;
        webView.scalesPageToFit = YES;
    }
    
    DownloadItem *item = [itemList objectAtIndex:indexValue];
    NSURL* url = [NSURL fileURLWithPath:item.localPath];    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    [self updateNavigationTitle:item.fileName];

}

- (void)setPreviousButton
{
    float buttonHigh = 27.5;
    float backButtonLen = 60;
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(8, 0, backButtonLen, buttonHigh)];
    [backButton setBackgroundImage:ITEM_NEXT_ICON_IMAGE forState:UIControlStateNormal];
    UIFont *font = [UIFont boldSystemFontOfSize:10];
    [backButton.titleLabel setFont:font];
    [backButton setTitleColor:[UIColor colorWithRed:99/255.0 green:124/255.0 blue:141/255.0 alpha:1.0] forState:UIControlStateNormal];
    [backButton setTitle:NSLS(@"kPrevious") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickPrevious:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];    
    self.navigationItem.leftBarButtonItem = leftBarButton;
    [leftBarButton release];
    
}

- (void)setNextButton
{
    float buttonHigh = 27.5;
    float nextButtonLen = 60;
    
    UIButton *nextButton = [[UIButton alloc]initWithFrame:CGRectMake(218, 0, nextButtonLen, buttonHigh)];
    
    [nextButton setBackgroundImage:ITEM_NEXT_ICON_IMAGE forState:UIControlStateNormal];
    UIFont *font = [UIFont boldSystemFontOfSize:10];
    [nextButton.titleLabel setFont:font];
    [nextButton setTitleColor:[UIColor colorWithRed:99/255.0 green:124/255.0 blue:141/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    [nextButton setTitle:NSLS(@"kNext") forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(clickNext:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:nextButton];    
    self.navigationItem.rightBarButtonItem = rightBarButton;
    [rightBarButton release];    
}


- (void)clickPrevious:(id)sender
{
    if (currentIndex > 0) {
        [self setCurrentIndex:currentIndex-1];
        
        NSArray *itemList = [self findAllRelatedItems];
        DownloadItem *item = [itemList objectAtIndex:currentIndex];
        NSURL* url = [NSURL fileURLWithPath:item.localPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self updateNavigationTitle:item.fileName];
    } else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLS(@"kTips") message:NSLS(@"kAlreadyFirst") delegate:self cancelButtonTitle:NSLS(@"kOK") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)clickNext:(id)sender
{
    NSArray *itemList = [self findAllRelatedItems];
    int totalCount = [itemList count];
    if (currentIndex < totalCount-1) {
        [self setCurrentIndex:currentIndex+1];
        
        DownloadItem *item = [itemList objectAtIndex:currentIndex];
        NSURL* url = [NSURL fileURLWithPath:item.localPath]; 
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
        [self updateNavigationTitle:item.fileName];
    } else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLS(@"kTips") message:NSLS(@"kAlreadyLast") delegate:self cancelButtonTitle:NSLS(@"kOK") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self setBackgroundImageName:DOWNLOAD_BG];
    [self setDownloadNavigationTitle:NSLS(@"kBook")];
    [self setPreviousButton];
    [self setNextButton];

    [self showBook:0];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
