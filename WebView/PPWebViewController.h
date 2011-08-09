//
//  PPWebViewController.h
//  FreeMusic
//
//  Created by qqn_pipi on 10-10-10.
//  Copyright 2010 QQN-PIPI.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"
#import "PPViewController.h"

extern TTWebController* GlobalGetWebController();



@interface PPWebViewController : PPViewController <UIWebViewDelegate> {
    
    UIWebView *webView;
    UIToolbar *toolbar;
    UIBarButtonItem *forwardButton;
    UIBarButtonItem *backButton;
    UIBarButtonItem *reloadButton;
    UIActivityIndicatorView *loadActivityIndicator;
    NSURLRequest *request;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *reloadButton;
@property (nonatomic, retain) UIActivityIndicatorView *loadActivityIndicator;

@property (nonatomic, retain) NSURLRequest *request;

- (IBAction) clickBackBuuton;
- (IBAction) clickForwardBuuton;
- (IBAction) clickReloadBuuton;
- (id)init;
- (void)openURL:(NSString *)URLString;

//delegate method
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end

extern PPWebViewController *GlobalGetPPWebViewController();