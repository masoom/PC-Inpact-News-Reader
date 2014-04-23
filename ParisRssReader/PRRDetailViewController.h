//
//  PRRDetailViewController.h
//  PC News Reader
//
//  Created by Masoom  on 02/04/14.
//  Copyright (c) 2014 EPITA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"
#import <MessageUI/MessageUI.h>
@interface PRRDetailViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MWFeedItem* detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblPublishDate;
- (IBAction)onClickViewArticle:(id)sender;
- (IBAction)onClickMail:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *contentView;
@property (weak, nonatomic) IBOutlet UIView *viewFacebook;
@property (weak, nonatomic) IBOutlet UIView *viewTwitter;
@property (weak, nonatomic) IBOutlet UIView *viewMail;
@end
