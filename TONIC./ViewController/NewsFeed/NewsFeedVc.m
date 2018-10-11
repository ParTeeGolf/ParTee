//
//  NewsFeedVc.m
//  ParTee
//
//  Created by Admin on 08/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "NewsFeedVc.h"
#import "EventTableViewCell.h"
#import "ArticleDetailsVC.h"
#import "NewsFeedTblViewCell.h"




@interface NewsFeedVc ()
{
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UITableView *tblList;
    IBOutlet UILabel *screenTitleLbl;
    IBOutlet UIView *instagramImgBaseView;
    IBOutlet NSLayoutConstraint *instaBaseViewHeightConstraints;
    IBOutlet UICollectionView *collectionView;
    
    int collectionViewItemStopped;
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;

    NSMutableString *guid;
    NSMutableString *description;
    NSMutableString *pubDate;
    NSMutableString *content;
     NSMutableString *creator;
    
    NSString *element;
    
}
@end

@implementation NewsFeedVc

- (void)viewDidLoad {
    [super viewDidLoad];
    

    collectionViewItemStopped = 0;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [collectionView setBackgroundColor:[UIColor redColor]];
    collectionView.scrollEnabled = NO;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    flow.minimumInteritemSpacing = 5;
    flow.minimumLineSpacing = 5;
    collectionView.collectionViewLayout = flow;
    
   // instagramImgBaseView.hidden = YES;
   // instaBaseViewHeightConstraints.constant = 0;
    
  //  http://images.apple.com/main/rss/hotnews/hotnews.rss
    // https://web.stagram.com/rss/n/mohittyagics
    // https://web.stagram.com/rss/n/parteegolfers
    feeds = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://www.partee.golf/feed.xml"];
  //  NSURL *url = [NSURL URLWithString:@"https://web.stagram.com/rss/n/mohittyagics"];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    
}
- (IBAction)prevInstaImagesLoad:(id)sender {
   
    collectionViewItemStopped -= 3;
    NSArray *visibleItems = [collectionView indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:collectionViewItemStopped inSection:currentItem.section];
    
    [collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
   
}
- (IBAction)nextInstaImagesAction:(id)sender {
    
    collectionViewItemStopped += 3;
    NSArray *visibleItems = [collectionView indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:collectionViewItemStopped inSection:currentItem.section];
    
    [collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
    
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        guid    = [[NSMutableString alloc] init];
        description = [[NSMutableString alloc] init];
        pubDate = [[NSMutableString alloc] init];
        content = [[NSMutableString alloc] init];
        creator = [[NSMutableString alloc] init];
    }
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
  
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    }else if ([element isEqualToString:@"guid"]) {
        [guid appendString:string];
    }else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    }else if ([element isEqualToString:@"pubDate"]) {
        [pubDate appendString:string];
    }else if ([element isEqualToString:@"content:encoded"]) {
        [content appendString:string];
    }else if ([element isEqualToString:@"dc:creator"]) {
        [creator appendString:string];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        [item setObject:guid forKey:@"guid"];
        [item setObject:description forKey:@"description"];
        [item setObject:pubDate forKey:@"pubDate"];
        [item setObject:content forKey:@"content"];
        [item setObject:creator forKey:@"creator"];
        [feeds addObject:[item copy]];
    }
    
   
    
}
//- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
//{
//    NSString *someString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", someString);
//}
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    NSLog(@"%@", feeds);
    [tblList reloadData];
    
}
/**
 @Description
 * This method will toggle left side menu to select other option from the side menu list.
 * @author Chetu India
 * @param sender sideMenu button avilable on navigation bar.
 * @return void nothing will return by this method.
 */
- (IBAction)sideMenuAction:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
#pragma mark - SegmentChangedAction
/**
 @Description
 * This method called when user change the segmnent control option from favourite, all, nearme, featured events.
 * @author Chetu India
 * @param segment option available on segment control.
 */
- (IBAction)segmentChangedAction:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 15;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    UIImageView *instaImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0 , cell.frame.size.width, cell.frame.size.height )];
    instaImgView.image = [UIImage imageNamed:@"demo_avatar_cook"];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 10.0;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    cell.layer.borderWidth = 3.0;
    [cell addSubview:instaImgView];
    cell.backgroundColor=[UIColor greenColor];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((collectionView.frame.size.width/3) - 5, (collectionView.frame.size.width/3) - 5 );
}
#pragma mark collection view cell paddings
//- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(5, 5, 5, 5); // top, left, bottom, right
//}

#pragma mark - Table view DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kEventNoSectionTbl;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kEventCellSize;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return 20;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsFeedTblViewCell *cell = [tableView dequeueReusableCellWithIdentifier:knewsFeedCellName];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:knewsFeedCellName owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        
        cell = [topLevelObjects objectAtIndex:kZeroValue];
        
    }
    [cell setFeedDataFromDict:[feeds objectAtIndex:indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    return cell;
    
}

#pragma mark - Table view Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ArticleDetailsVC *obj = [[ArticleDetailsVC alloc] initWithNibName:kArticleDetailVc bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
