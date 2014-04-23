//
//  PRRMasterViewController.m
//  PC News Reader
//
//  Created by Masoom  on 02/04/14.
//  Copyright (c) 2014 EPITA. All rights reserved.
//

#import "PRRMasterViewController.h"
#import "NSString+HTML.h"
#import "MWFeedParser.h"
#import "PRRDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "RelativeDateDescriptor.h"
#import <QuartzCore/QuartzCore.h>

@interface PRRMasterViewController () {
    RelativeDateDescriptor *descriptor;
}
@end

@implementation PRRMasterViewController

@synthesize itemsToDisplay;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // self.navigationItem.leftBarButtonItem = self.editButtonItem;

    // Setup
	self.title = @"Loading...";
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	parsedItems = [[NSMutableArray alloc] init];
	self.itemsToDisplay = [NSArray array];
	
	// Refresh button
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refresh)];
    // Custom XML Feed Specified
    NSURL *feedURL = [NSURL URLWithString:@"http://www.pcinpact.com/rss/news.xml"];
    
    
	feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	[feedParser parse];
    
    descriptor = [[RelativeDateDescriptor alloc] initWithPriorDateDescriptionFormat:@"%@ ago" postDateDescriptionFormat:@"%@"];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDictionary *retrievedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"DicUrlKey"];
    
    
    if (!retrievedDictionary) {
        NSMutableDictionary *dic = [[NSMutableDictionary  alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"DicUrlKey"];
    }
    

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Parsing

// Reset and reparse
- (void)refresh {
	self.title = @"Refreshing...";
	[parsedItems removeAllObjects];
	[feedParser stopParsing];
	[feedParser parse];
	self.tableView.userInteractionEnabled = NO;
	self.tableView.alpha = 0.3;
}

- (void)updateTableWithParsedItems {
	self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
						   [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                                ascending:NO]]];
	self.tableView.userInteractionEnabled = YES;
	self.tableView.alpha = 1;
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	NSLog(@"Parsed Feed Info: “%@”", info.title);
	// self.title = info.title;
    self.title = @"NEWS";
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
    
	if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self updateTableWithParsedItems];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        self.title = @"Failed"; // Show failed message in title
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self updateTableWithParsedItems];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemsToDisplay.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *retrievedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"DicUrlKey"];

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
	MWFeedItem *item = [self.itemsToDisplay objectAtIndex:indexPath.row];
	if (item) {
		
		// Process
		NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
		NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
        NSString *itemLink = item.link;
        
		
        NSString *imageUrl = @"";
        NSLog(@"item.enclosures count = %d", [item.enclosures count]);
        if ([item.enclosures count] > 0) {
            imageUrl = [item.enclosures[0] objectForKey:@"url"];
        }

		// Set
        UILabel *titleLabel = (UILabel*) [cell viewWithTag:2];
        UILabel *detailLabel = (UILabel *)[cell viewWithTag:3];
        UIView *favView = (UIView *) [cell viewWithTag:4];
        
        titleLabel.text = itemTitle;
        NSMutableString *subtitle = [NSMutableString string];
		if (item.date) {
            // [subtitle appendFormat:@"%@: ", [formatter stringFromDate:item.date]];
            [subtitle appendFormat:@"%@:", [descriptor describeDate:[NSDate date] relativeTo:item.date]];
        }
		[subtitle appendString:itemSummary];
		
        detailLabel.text = subtitle;
        
        if ([imageUrl length] > 0) {
            UIImageView *imageView = (UIImageView*) [cell viewWithTag:1];
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl]
                       placeholderImage:[UIImage imageNamed:@"no_camera_sign"]
                               options:SDWebImageRefreshCached];
            
        }
		
        favView.layer.cornerRadius = 8;
        favView.layer.masksToBounds = YES;
        if ([retrievedDictionary objectForKey:itemLink]) { // already favourite
            favView.hidden = NO;
        } else { //
            favView.hidden = YES;
        }

	}
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelAll];
	// Show detail
	PRRDetailViewController *detail = (PRRDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
	[detail setDetailItem:(MWFeedItem *)[self.itemsToDisplay objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:detail animated:YES];
	
	// Deselect
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}


@end
