//
//  PRRMasterViewController.h
//  PC News Reader
//
//  Created by Masoom  on 02/04/14.
//  Copyright (c) 2014 EPITA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"
@interface PRRMasterViewController : UITableViewController <MWFeedParserDelegate> {
    // Parsing
	MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
	
	// Displaying
	NSArray *itemsToDisplay;
	NSDateFormatter *formatter;
}


// Properties
@property (nonatomic, strong) NSArray *itemsToDisplay;


@end
