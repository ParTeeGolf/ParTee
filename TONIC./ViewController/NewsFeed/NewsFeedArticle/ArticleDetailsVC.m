//
//  ArticleDetailsVC.m
//  ParTee
//
//  Created by Chetu India on 08/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "ArticleDetailsVC.h"

@interface ArticleDetailsVC ()
{
    /*********** IBOutlets *************/
    // constraints title txtView.
    IBOutlet NSLayoutConstraint *titleTxtViewHeight;
    // Title of the article.
    IBOutlet UITextView *articleTiltleTxtView;
    //  Article image.
    IBOutlet UIImageView *articleImgView;
    // Webview To show the content.
    IBOutlet UIWebView *descWebView;
    /*********** IBOutlets *************/
    
    /*********** Varibles to store Values related to article *******/
    NSString *titleStr;
    NSString *descStr;
    NSString *contentStr;
    NSString *pubDate;
    NSString *guidStr;
    NSString *linkStr;
    /*********** Varibles to store Values related to article *******/
    // string used to construct java script string in order to change the font size of the text.
    NSString *javaScriptStrToChangeFontSize;
}

@end

@implementation ArticleDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_AdFeedObj) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:kFormatOriginalCreatedDate];
        NSString *finalDate = [dateFormat stringFromDate:_AdFeedObj.createdAt];
        NSString *dateStr = [CommonMethods convertDateToAnotherFormat:finalDate originalFormat:kFormatOriginalCreatedDate finalFormat:kfinalFormat];
        titleStr = [[AppDelegate sharedinstance] nullcheck:[_AdFeedObj.fields objectForKey:kAdTitle]];
        descStr  = [[AppDelegate sharedinstance] nullcheck:[_AdFeedObj.fields objectForKey:kAdDesc]];
        contentStr =  [[AppDelegate sharedinstance] nullcheck:[_AdFeedObj.fields objectForKey:kAdContent]];
        pubDate = dateStr;
     //   guidStr = [[AppDelegate sharedinstance] nullcheck:[_AdFeedObj.fields objectForKey:kAdCreater]];
        linkStr = [[AppDelegate sharedinstance] nullcheck:[_AdFeedObj.fields objectForKey:kAdLink]];
    }else{
     
       titleStr =  [[AppDelegate sharedinstance] nullcheck:[_articleDetailDict objectForKey:kFeedTitleParam]];
       descStr  = [[AppDelegate sharedinstance] nullcheck:[_articleDetailDict objectForKey:kFeedDescParam]];
       contentStr =  [[AppDelegate sharedinstance] nullcheck:[_articleDetailDict objectForKey:kInstaFeedContent]];
       pubDate = [[AppDelegate sharedinstance] nullcheck:[_articleDetailDict objectForKey:kFeedDateParam]];
       guidStr = [[AppDelegate sharedinstance] nullcheck:[_articleDetailDict objectForKey:kFeedGuidParam]];
       linkStr = [[AppDelegate sharedinstance] nullcheck:[_articleDetailDict objectForKey:kFeedLinkParam]];
        
    }
    [self setDataForScreen];
    
}

#pragma mark - setData On Screen
/**
 @Description
 * This Method set the data on screen based type of cell selected.
 * @author Chetu India
 * @param titleStr  title of the article.
 * @param descStr  img str link to show.
 * @param contentStr  content str to show on webview..
 * @return void nothing will return by this method.
 */
-(void)setDataForScreen
{
    CGFloat heightTitleTextview  =  [CommonMethods heightForText:titleStr withFont:[UIFont systemFontOfSize:37] andWidth:articleTiltleTxtView.frame.size.width];
    
    if (heightTitleTextview > 150) {
        titleTxtViewHeight.constant = 150;
    }else {
        titleTxtViewHeight.constant = heightTitleTextview;
    }
    
    [articleImgView sd_setImageWithURL:[NSURL URLWithString:descStr] placeholderImage:[UIImage imageNamed:kUnSpecifiedPng]];
    articleTiltleTxtView.text = titleStr;
    [articleTiltleTxtView scrollRangeToVisible:NSMakeRange(0, 1)];
    [descWebView setOpaque:NO];
    descWebView.backgroundColor = [UIColor clearColor];
    if (_adFeedVal) {
        [descWebView loadHTMLString:[NSString stringWithFormat:@"<div align='justify'>%@<div>",contentStr] baseURL:nil];
    }else{
       
        NSArray *listItems = [contentStr componentsSeparatedByString:@"\""];
        if (listItems.count == 3) {
            NSString *separateStr1 = [listItems objectAtIndex:0];
            NSString *separateStr2 = [listItems objectAtIndex:1];
            NSString *separateStr3 = [listItems objectAtIndex:2];
            NSString *combinedStr = [NSString stringWithFormat:@"%@\"%@\" width='100%%' height='100%%'%@",separateStr1, separateStr2, separateStr3];
            contentStr = combinedStr;
        }
     
        [descWebView  loadHTMLString:[NSString stringWithFormat:@"<html><body><span style=\"text-align:justify\">%@</span></body></html>",contentStr] baseURL:nil];
    }
}
#pragma mark - Webview delegate method
/**
 @Description
 * Sent after a web view finishes loading a frame.
 * @author Chetu India
 * @param _webView  to show on webview..
 * @return void nothing will return by this method.
 */
- (void)webViewDidFinishLoad:(UIWebView *)_webView{
    
    if (_adFeedVal) {
        javaScriptStrToChangeFontSize = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white';document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='140%%';DOMReady();"];
    }else {
        javaScriptStrToChangeFontSize = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white';document.getElementsByTagName('div')[0].style.backgroundColor='clear';document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='140%%'; DOMReady();"];
    }
    
     [descWebView stringByEvaluatingJavaScriptFromString:javaScriptStrToChangeFontSize];
    
}
#pragma mark - Fav Button Action
/**
 @Description
 * show popup to large, small, share text via social networking application.
 * @author Chetu India
 */
- (IBAction)favBtnAction:(id)sender {
    [self showGrid];
}
- (void)showGrid {
    NSInteger numberOfOptions = kThreeValue;
    NSArray *items;
    items= @[
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:kLargeTxtFeedImg] title:kLargeTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:kSmallTxtImg] title:kSmallTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:kShareImg] title:kShareTitle]
             ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.itemFont = [UIFont fontWithName:@"Montserrat-Bold" size:28.f];
    av.delegate = self;
    av.bounces = YES;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}
#pragma mark- grid Delegate
/**
 @Description
 * This is the delagate method of grid menu it will called when user select any options from grid popup.
 * @author Chetu India
 * @param gridMenu
 * @param item option selected from the grid.
 * @param itemIndex is the number to identify which options user seelcted from the grid,
 * @return void nothing will return by this method.
 */
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    
    switch(itemIndex)
    {
        case kIndexShare:
            [self shareLinkViaSocialApp];
            break;
        case kIndexLarge:
            [self textLargeArticle];
            break;
        case kIndexSmall:
            [self textSmallArticle];
            break;
    }
}
#pragma mark- grid Delegate
/**
 @Description
 * Share artcile link via social networking application available on the device.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)shareLinkViaSocialApp
{
    NSArray * activityItems = @[[NSString stringWithFormat:@"%@",linkStr]];
    NSArray * applicationActivities = nil;
    NSArray * excludeActivities = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeMessage];
    
    UIActivityViewController * activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityController.excludedActivityTypes = excludeActivities;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        activityController.popoverPresentationController.sourceView = self.view;
        
        [self presentViewController:activityController
                           animated:YES
                         completion:nil];
    }
    else
    {
        [self presentViewController:activityController
                           animated:YES
                         completion:nil];
    }
}
#pragma mark- Large Text
/**
 @Description
 * large the content font size on webview using java scritp.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)textLargeArticle
{
    if (_adFeedVal) {
        javaScriptStrToChangeFontSize = [[NSString alloc]      initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white';document.getElementsByTagName('div')[0].style.backgroundColor='clear';document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='200%%';"];
      
    }else {
        javaScriptStrToChangeFontSize = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white';document.getElementsByTagName('div')[0].style.backgroundColor='clear';document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='200%%'; DOMReady();"];
    }
      [descWebView stringByEvaluatingJavaScriptFromString:javaScriptStrToChangeFontSize];
    
    
}
#pragma mark- Small Text
/**
 @Description
 * small the content font size on webview using java scritp.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)textSmallArticle
{

    if (_adFeedVal) {
           javaScriptStrToChangeFontSize = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white';document.getElementsByTagName('div')[0].style.backgroundColor='clear';document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='140%%';"];
    
    }else {
        javaScriptStrToChangeFontSize = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white';document.getElementsByTagName('div')[0].style.backgroundColor='clear';document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='140%%'; DOMReady();"];
    }
    [descWebView stringByEvaluatingJavaScriptFromString:javaScriptStrToChangeFontSize];
}
#pragma mark - Back Button Action
/**
 @Description
 * This Method pop this controller after shown the popup that have two button yes or No. If user press yes the event will be filter out based on preferences while if user pressed no then all events will be shown in event screen.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)backSideMenuAction:(id)sender {
    
       [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
