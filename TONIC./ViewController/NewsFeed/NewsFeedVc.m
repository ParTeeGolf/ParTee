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
        /************* IBOutlets for newsFeed Screen ***************/
        IBOutlet UILabel *headerTitleLbl;
        IBOutlet UISegmentedControl *segmentControl;
        // table view to show the rss feed items available on rss feed url.
        IBOutlet UITableView *tblList;
        IBOutlet UIView *instagramImgBaseView;
        IBOutlet NSLayoutConstraint *instaBaseViewHeightConstraints;
        // Used to show the instagram images fecthed from instagram Account
        IBOutlet UICollectionView *collectionView;
        // Next Button to load next images from instagarm.
        IBOutlet UIButton *nextInstaImageBtn;
        // Prev Button to load previous images from instagarm.
        IBOutlet UIButton *prevInstaImageBtn;
        /************* IBOutlets for newsFeed Screen ***************/
        // Varible used to store the collectionView Last And First item index value.
        int collectionViewLastItemIndex;
        int collectionViewFirstItemIndex;
        // NSXMLParser used to fecth the data from rss feed url.
        NSXMLParser *parser;
        // Array to store the feeds details available on rss feed url.
        NSMutableArray *feeds;
        // item to store the feeds value in dictionary.
        NSMutableDictionary *item;
        /*********** strings used to store values for the item available on rss feed url. ********/
        NSMutableString *title;
        NSMutableString *link;
        NSMutableString *guid;
        NSMutableString *description;
        NSMutableString *pubDate;
        NSMutableString *content;
        NSMutableString *creator;
        // varible to check wheather parser is parsing rss feed or Insta feed. value 0 means parsing feed otherwise parsing instagram feed.
        int xmlParserTagValue;
        /*********** strings used to store values for the Instagram feed item available on rss feed url. ********/
        NSString *element;
        NSMutableArray  *instaFeeds;
        NSMutableString *instaTitle;
        NSMutableString *instaLink;
        NSMutableString *instaDesc;
        NSMutableString *instaPubDate;
        NSMutableString *instaLang;
        NSMutableString *instaCreater;
        NSMutableString *instaThumbnail;
        
        // conatin current page number for advertisement events.
        int adCurrentPage;
        // This array contain AdEvents details fetched from the quickblox table.
        NSMutableArray *arrAdFeedDetails;
        // total needed adfeed
        int needAdFeedCount;
        // contain total number of ad feed available on quickblox table.
        int totalAdfeedAvailable;
        // contain total number of ad feed available on quickblox table.
        int totalAdvertFeedCount;
        // contain total number of news feed available on quickblox table.
        int feedsCount;
        
    }
    @end

    @implementation NewsFeedVc

    - (void)viewDidLoad {
        [super viewDidLoad];
        // Show Loader
        [[AppDelegate sharedinstance] showLoader];
        // Using flow layout to show only single item horizontally.
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flow.minimumInteritemSpacing               = kThreeValue;
        flow.minimumLineSpacing                    = kThreeValue;
        collectionView.collectionViewLayout        = flow;
        [self initializeVariables];
    }

    -(void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:NO];
    }
    #pragma mark- Initailize data
    /**
     @Description
     * This method will initailize the variable.
     * @author Chetu India
     * @return void nothing will return by this method.
     */
    -(void)initializeVariables
    {
        totalAdvertFeedCount                       = kZeroValue;
        totalAdfeedAvailable                       = kZeroValue;
        needAdFeedCount                            = kZeroValue;
        adCurrentPage                              = kZeroValue;
        instaBaseViewHeightConstraints.constant    = kZeroValue;
        collectionViewFirstItemIndex               = kZeroValue;
        collectionViewLastItemIndex                = kThreeValue;
        feedsCount                                 = kZeroValue;
        // Initialize array used to store the details of advertiement feed from quickblox table.
        arrAdFeedDetails                           = [[NSMutableArray alloc]init];
        // Initialize arrays used to store the data of rss Feeds.
        feeds                                      = [[NSMutableArray alloc] init];
        instaFeeds                                 = [[NSMutableArray alloc]init];
        instagramImgBaseView.hidden                = YES;
        collectionView.scrollEnabled               = NO;
        // hide separator lines of table view.
        tblList.separatorColor                     = [UIColor clearColor];
        
        // Call methods after delay.
        [self performSelector:@selector(getDataFromRssFeedUrl) withObject:self afterDelay:0.01 ];
    }

    #pragma mark- Get Data Rss Feed
    /**
     @Description
     * This method will get the data from rss feed.
     * @author Chetu India
     * @return void nothing will return by this method.
     */
    -(void)getDataFromRssFeedUrl
    {
        // Initialize array that contain url for rssfeed from which data need to be fetched.
        NSMutableArray *urlArray = [[NSMutableArray alloc]init];
        [urlArray addObject:kNewsFeedUrl];
        [urlArray addObject:kInstaFeedUrl];
        for (NSString *urlStr in urlArray) {
            
            if ([urlStr isEqualToString:kNewsFeedUrl]) {
                xmlParserTagValue = kZeroValue;
            }else if ([urlStr isEqualToString:kInstaFeedUrl]){
                xmlParserTagValue = 1;
            }
            // Parser used to parse xml data from url.
            NSURL *url = [NSURL URLWithString:urlStr];
            parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            [parser parse];
            
        }
        
    }
    #pragma mark- Delegate Methods NSXMLParser
    /**
     @Description
     * Sent by a parser object to its delegate when it encounters a start tag for a given element.
     * @author Chetu India
     * @return void nothing will return by this method.
     */
    - (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
        element = elementName;
        
        // Initialize vaiables to store the item data.
        if (xmlParserTagValue == 0) {
            
            if ([element isEqualToString:kParserItem]) {
                
                item    = [[NSMutableDictionary alloc] init];
                title   = [[NSMutableString alloc] init];
                link    = [[NSMutableString alloc] init];
                guid    = [[NSMutableString alloc] init];
                description = [[NSMutableString alloc] init];
                pubDate = [[NSMutableString alloc] init];
                content = [[NSMutableString alloc] init];
                creator = [[NSMutableString alloc] init];
            }
        }else if (xmlParserTagValue == 1){
            
            if ([element isEqualToString:kParserItem]) {
                
                item                 = [[NSMutableDictionary alloc] init];
                instaTitle           = [[NSMutableString alloc] init];
                instaCreater         = [[NSMutableString alloc] init];
                instaPubDate         = [[NSMutableString alloc] init];
                instaDesc            = [[NSMutableString alloc] init];
                instaLang            = [[NSMutableString alloc] init];
                instaLink            = [[NSMutableString alloc] init];
                
            }else  if ( [elementName isEqualToString:kMediaThumbnail] )
            {
                instaThumbnail       = [[NSMutableString alloc] init];
                instaThumbnail = [attributeDict valueForKey:kInstaUrl];
            }
        }
    }
    - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
        
        
        
        if (xmlParserTagValue == 0) {
            if ([element isEqualToString:kFeedTitleParam]) {
                [title appendString:string];
            } else if ([element isEqualToString:kFeedLinkParam]) {
                [link appendString:string];
            }else if ([element isEqualToString:kFeedGuidParam]) {
                [guid appendString:string];
            }else if ([element isEqualToString:kFeedDescParam]) {
                [description appendString:string];
            }else if ([element isEqualToString:kFeedDateParam]) {
                [pubDate appendString:string];
            }else if ([element isEqualToString:kFeedContentParam]) {
                [content appendString:string];
            }else if ([element isEqualToString:kFeedCreatorParam]) {
                [creator appendString:string];
            }
        }else if (xmlParserTagValue == 1){
            if ([element isEqualToString:kFeedTitleParam]) {
                [instaTitle appendString:string];
            } else if ([element isEqualToString:kFeedLinkParam]) {
                [instaLink appendString:string];
            }else if ([element isEqualToString:kFeedLangParam]) {
                [instaLang appendString:string];
            }else if ([element isEqualToString:kFeedDescParam]) {
                [instaDesc appendString:string];
            }else if ([element isEqualToString:kFeedDateParam]) {
                [instaPubDate appendString:string];
            }else if ([element isEqualToString:kFeedCreatorParam]) {
                [instaCreater appendString:string];
            }
        }
    }

    - (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
        
        if (xmlParserTagValue == 0) {
            
            if ([elementName isEqualToString:kParserItem]) {
                
                [item setObject:title forKey:kFeedTitleParam];
                [item setObject:link forKey:kFeedLinkParam];
                [item setObject:guid forKey:kFeedGuidParam];
                [item setObject:description forKey:kFeedDescParam];
                [item setObject:pubDate forKey:kFeedDateParam];
                [item setObject:content forKey:kInstaFeedContent];
                [item setObject:creator forKey:kInstaFeedCreater];
                [feeds addObject:[item copy]];
            }
        }else if (xmlParserTagValue == 1){
            if ([elementName isEqualToString:kParserItem]) {
                
                [item setObject:instaTitle forKey:kInstaFeedTitle];
                [item setObject:instaLink forKey:kInstaFeedLink];
                [item setObject:instaDesc forKey:kInstaFeedDesc];
                [item setObject:instaPubDate forKey:kInstaFeedPubDate];
                [item setObject:creator forKey:kInstaFeedCreator];
                [item setObject:instaThumbnail forKey:kInstaFeedThumbnail];
                [item setObject:creator forKey:kFeedCreatorParam];
                [instaFeeds addObject:[item copy]];
            }
        }
    }
    - (void)parserDidEndDocument:(NSXMLParser *)parser {
        
        if (xmlParserTagValue == kZeroValue) {
            
            feedsCount = (int)feeds.count;
            // Convert text fecthed in description to link just by removing the xml elements.
            for (int i = kZeroValue; i < feedsCount; i++) {
                
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                NSDictionary *oldDict = (NSDictionary *)[feeds objectAtIndex:i];
                
                NSString *descStrWithHtml = [oldDict objectForKey:kFeedDescParam];
                NSData* descData = [descStrWithHtml dataUsingEncoding:NSUTF8StringEncoding];
                NSString *imageUrlStr = [CommonMethods convertDataToLink:descData];
                [newDict addEntriesFromDictionary:oldDict];
                [newDict setObject:imageUrlStr forKey:kFeedDescParam];
                // Repalce the old dict with new dict.
                [feeds replaceObjectAtIndex:i withObject:newDict];
            }
        }else if (xmlParserTagValue == 1){
            [collectionView reloadData];
            [self getAdFeedCount];
            
        }
    }

    #pragma mark- Get AdEvent Count
    /**
     @Description
     * This method will count the advertisement Feed available in AdNewsFeed table on quickblox.
     * @author Chetu India
     * @return void nothing will return by this method.
     */
    -(void)getAdFeedCount
    {
        
        // Create Dictionary for parameters used to fetch Advertisement records available in the adEvents table on quickblox.
        NSMutableDictionary *getRequestObjectCount = [NSMutableDictionary dictionary];
        // Add parameters for count the records available in the  table.
        [getRequestObjectCount setObject:kEventOneStr forKey:kEventCount];
        
        [QBRequest countObjectsWithClassName:kAdNewsFeedTblName extendedRequest:getRequestObjectCount successBlock:^(QBResponse * _Nonnull response, NSUInteger count) {
            
            NSLog(@"%lu",(unsigned long)count);
            // Total number of advertisment events available in AdEvent table on Quickblox.
            totalAdvertFeedCount = (int)count;
            [self getAdFeedDetails];
            
        } errorBlock:^(QBResponse *response) {
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
    /**
     @Description
     * This will fetch the AdFeed details.
     * @author Chetu India
     * @return void nothing will return by this method.
     */
    -(void) getAdFeedDetails
    {
        
        // Create dictionary for parameters to filter out the records from AdEvents table on quickblox
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        
        
        [getRequest setObject:kAdEventLimit forKey:kEventLimitParam];
        NSString *strPage = [NSString stringWithFormat:@"%d",[kAdEventLimit intValue] * adCurrentPage];
        [getRequest setObject:strPage forKey:kEventSkipParam];
        
        [QBRequest objectsWithClassName:kAdNewsFeedTblName extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            
            NSLog(@"%lu",(unsigned long)objects.count);
            // Add the Ad Event record details in array.
            [arrAdFeedDetails addObjectsFromArray:[objects mutableCopy]];
            totalAdfeedAvailable = (int)[arrAdFeedDetails count];
            
            // Arrange events randomly in array so that we able to show the advertisement events randomly on screen.
            for (int x = kZeroValue; x < totalAdfeedAvailable; x++) {
                int randInt = (arc4random() % (totalAdfeedAvailable - x)) + x;
                [arrAdFeedDetails exchangeObjectAtIndex:x withObjectAtIndex:randInt];
            }
            
            // get the total number of needed advertisment events so that every 5th events will show as advertisment events on screen.
            needAdFeedCount = feedsCount;
            needAdFeedCount = needAdFeedCount / (kAdvertisementEventNo -1);
            // Compare need Ad Events with available ad events that have been fetched from quickblox. If needed events are more and there are still available records in the table then fetch rest of advertisement events again.
            if (needAdFeedCount > totalAdfeedAvailable ) {
                
                if (totalAdvertFeedCount > totalAdfeedAvailable ) {
                    adCurrentPage++;
                    [self getAdFeedDetails];
                }else {
                    [tblList reloadData];
                    [[AppDelegate sharedinstance] hideLoader];
                }
                
            }else {
                [tblList reloadData];
                [[AppDelegate sharedinstance] hideLoader];
            }
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
    }
    /**
     @Description
     * This method will display previous instagram images on collection views.
     * @author Chetu India
     */

    - (IBAction)prevInstaImagesLoad:(id)sender {
        
        
        // Check wheather need to load first three record or not.
        if ((collectionViewFirstItemIndex) <= 3) {
            collectionViewFirstItemIndex = 0;
            prevInstaImageBtn.hidden = YES;
            nextInstaImageBtn.hidden = NO;
        }else {
            prevInstaImageBtn.hidden = NO;
            nextInstaImageBtn.hidden = NO;
            collectionViewFirstItemIndex -= 3;
            
        }
        
        // Scroll collection view to item at index path.
        NSArray *visibleItems = [collectionView indexPathsForVisibleItems];
        NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:collectionViewFirstItemIndex  inSection:currentItem.section];
        [collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        collectionViewLastItemIndex = collectionViewFirstItemIndex + 3;
        
    }
    /**
     @Description
     * This method will display next instagram images on collection views.
     * @author Chetu India
     */
    - (IBAction)nextInstaImagesAction:(id)sender {
        
        // Check wheather need to load last three record or not.
        if ((collectionViewLastItemIndex + 3) >= instaFeeds.count) {
            nextInstaImageBtn.hidden = YES;
            collectionViewLastItemIndex = (int)instaFeeds.count - 1;
        }else{
            collectionViewLastItemIndex += 3;
            prevInstaImageBtn.hidden = NO;
        }
        // Scroll collection view to item at index path.
        NSArray *visibleItems = [collectionView indexPathsForVisibleItems];
        NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
        NSIndexPath *nextItem = [NSIndexPath indexPathForItem:collectionViewLastItemIndex - 1 inSection:currentItem.section];
        [collectionView scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        // Check wheather need to load last three record or not.
        if (collectionViewLastItemIndex >= instaFeeds.count ) {
            collectionViewLastItemIndex = (int)instaFeeds.count - 1;
        }else{
            
        }
        collectionViewFirstItemIndex = collectionViewLastItemIndex - 3;
        
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
        int selectedIndex = (int)selectedSegment;
        if (selectedIndex == kZeroValue) {
            headerTitleLbl.text = kFeedMorningReadTitle;
            instaBaseViewHeightConstraints.constant = kZeroValue;
            instagramImgBaseView.hidden = YES;
        }else if (selectedIndex == 1) {
            headerTitleLbl.text = kFeedParteeLineTitle;
            instaBaseViewHeightConstraints.constant = 120 ;
            instagramImgBaseView.hidden = NO;
        }
    }

    #pragma mark - Collection view DataSource Methods

    - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
    {
        // return 6 if data not available for now.
        if (instaFeeds.count == 0) {
            return 6;
        }
        return instaFeeds.count;
    }
    - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
    {
        UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
        UIImageView *instaImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0 , cell.frame.size.width, cell.frame.size.height )];
        // show instagram images on collection view cell.
        if (instaFeeds.count != 0) {
            [instaImgView sd_setImageWithURL:[NSURL URLWithString:[[instaFeeds objectAtIndex:indexPath.item] objectForKey:kInstaFeedThumbnail]] placeholderImage:[UIImage imageNamed:kUnSpecifiedPng]];
        }else{
            instaImgView.image = [UIImage imageNamed:kUnSpecifiedPng];
        }
        
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = 10.0;
        cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
        cell.layer.borderWidth = 2.0;
        [cell addSubview:instaImgView];
        return cell;
    }

    - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
    {
        return CGSizeMake((collectionView.frame.size.width - 7)/3 , (collectionView.frame.size.width - 7)/3);
    }

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
        // Return 10 if nany data available.
        if (feedsCount == kZeroValue) {
            return 10;
        }
        // get total number of cells required to show the feed data and adfeed data on table from rss feed and quickblox respectively.
        int numberOfFeedsToDisplay = kZeroValue;
        if (needAdFeedCount > totalAdfeedAvailable ) {
            // Ad Feed are less than required one.
            numberOfFeedsToDisplay = feedsCount + totalAdfeedAvailable;
            
        }else {
            numberOfFeedsToDisplay = feedsCount + needAdFeedCount;
        }
        
        return numberOfFeedsToDisplay;
        
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
        // Find which cell (adFeed or NewsFeed )need to display on indexpath.
        if (feedsCount != kZeroValue) {
            int indexValue = (int)indexPath.row;
            if (needAdFeedCount > totalAdfeedAvailable ) {
                
                // Ad Feed are less than required one.
                int maxFeedCount = totalAdfeedAvailable * 4;
                int  totalFeed = maxFeedCount + totalAdfeedAvailable;
                if (totalFeed - 1 > indexValue) {
                    int remainder = indexValue % kAdvertisementEventNo;
                    if (remainder == 4) {
                        int arrIndex = ((indexValue + 1) /kAdvertisementEventNo) - 1 ;
                        [cell setAdFeedDataFromQbObj:[arrAdFeedDetails objectAtIndex:arrIndex]];
                    }else {
                        int numberadvertFeedsCount = indexValue - (int)(indexValue / kAdvertisementEventNo);
                        [cell setFeedDataFromDict:[feeds objectAtIndex:numberadvertFeedsCount]];
                    }
                }else {
                    
                    int indexArr = indexValue - totalAdfeedAvailable;
                    [cell setFeedDataFromDict:[feeds objectAtIndex:indexArr]];
                }
                
            }else {
                int remainder = indexValue % kAdvertisementEventNo;
                if (remainder == 4) {
                    
                    int arrIndex = ((indexValue + 1) /kAdvertisementEventNo) - 1 ;
                    [cell setAdFeedDataFromQbObj:[arrAdFeedDetails objectAtIndex:arrIndex]];
                    cell.adminNameLbl.textColor = [UIColor redColor];
                }else {
                    int numberadvertFeedsCount = indexValue - (int)(indexValue / kAdvertisementEventNo);
                    [cell setFeedDataFromDict:[feeds objectAtIndex:numberadvertFeedsCount]];
                }
            }
            
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }

    #pragma mark - Table view Delegate

    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
        BOOL                adFeedVal;
        int objIndexVal                  = kZeroValue;
        // Get indexpath row value
        int indexValue = (int)indexPath.row;
        int remainder = indexValue % kAdvertisementEventNo;
        // Logic to find which cell seleted by user.
        
        // Check for do we have enough adFeed available in quickblox table.
        if (needAdFeedCount > totalAdfeedAvailable ) {
            
            // Ad Feed are less than required one.
            int maxFeedCount = totalAdfeedAvailable * 4;
            int  totalFeed = maxFeedCount + totalAdfeedAvailable;
            if (totalFeed - 1 > indexValue) {
                
                if (remainder == 4) {
                    
                    // Seleced cell is adEvent Cell.
                    objIndexVal = (indexValue + 1) / kAdvertisementEventNo;
                    adFeedVal = YES;
                    
                }else {
                    // selected cell is news feed cell.
                    objIndexVal = indexValue - (int)(indexValue / kAdvertisementEventNo);
                    adFeedVal = NO;
                }
                
            }else {
                // selected cell is news feed cell.
                objIndexVal = indexValue - totalAdfeedAvailable;
                adFeedVal = NO;
            }
            
        }else {
            // Ad Feed are more enough avaliable than required one.
            if (remainder == 4) {
                // selected cell is a Adfeed cell.
                objIndexVal = ((indexValue + 1) / kAdvertisementEventNo) - 1;
                adFeedVal = YES;
                
            }else {
                // Selected cell is News Feed cell.
                objIndexVal = indexValue - (int)(indexValue / kAdvertisementEventNo);
                adFeedVal = NO;
            }
            
        }
        
        // Call method to push the article controller based on type of cell wheather it is adfeed or news feed.
        if (adFeedVal) {
            [self pushControllerToArticleScreen:adFeedVal NewsFeedDIct:nil adFeed:[arrAdFeedDetails objectAtIndex:objIndexVal]];
        }else{
            [self pushControllerToArticleScreen:adFeedVal NewsFeedDIct:[feeds objectAtIndex:objIndexVal] adFeed:nil];
        }
        
    }
    #pragma mark - SegmentChangedAction
    /**
     @Description
     * This method Call method to push the article controller based on type of cell wheather it is adfeed or news feed.
     * @author Chetu India
     * @param segment option available on segment control.
     */
    -(void)pushControllerToArticleScreen:(BOOL)adFeedVal NewsFeedDIct:(NSDictionary *)newsfeedDict adFeed:(QBCOCustomObject *)adfeedObj
    {
        if (adFeedVal) {
            ArticleDetailsVC *articleObj = [[ArticleDetailsVC alloc] initWithNibName:kArticleDetailVc bundle:nil];
            articleObj.AdFeedObj = adfeedObj;
            articleObj.adFeedVal = adFeedVal;
            [self.navigationController pushViewController:articleObj animated:YES];
        }else{
            ArticleDetailsVC *articleObj = [[ArticleDetailsVC alloc] initWithNibName:kArticleDetailVc bundle:nil];
            articleObj.articleDetailDict = newsfeedDict;
            articleObj.adFeedVal = adFeedVal;
            [self.navigationController pushViewController:articleObj animated:YES];
        }
    }
    - (void)didReceiveMemoryWarning {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    @end
