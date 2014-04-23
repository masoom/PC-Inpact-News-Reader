//
//  PRRDetailViewController.m
//  PC News Reader
//
//  Created by Masoom  on 02/04/14.
//  Copyright (c) 2014 EPITA. All rights reserved.
//

#import "PRRDetailViewController.h"
#import "NSString+HTML.h"
#import "UIImageView+WebCache.h"
#import "BButton.h"

@interface PRRDetailViewController () {
    NSDateFormatter *formatter;
}
- (void)configureView;
@end

@implementation PRRDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        
        formatter = [[NSDateFormatter alloc] init];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        NSString *title = _detailItem.title ? [_detailItem.title stringByConvertingHTMLToPlainText] : @"[No Title]";
        self.title = title;
        self.lblPublishDate.text = [NSString stringWithFormat:@"%@ | %@", [formatter stringFromDate:_detailItem.date], title];
        self.contentView.text = _detailItem.summary ? [_detailItem.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
        
        NSString *imageUrl = @"";
        if ([_detailItem.enclosures count] > 0) {
            imageUrl = [_detailItem.enclosures[0] objectForKey:@"url"];
        }
        
        [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl]
                  placeholderImage:[UIImage imageNamed:@"no_camera_sign"]
                           options:SDWebImageRefreshCached];
        
        [self updateFavouriteButton];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self.navigationController.navigationBar setTranslucent:YES];
    
    BButton *btn = [[BButton alloc] initWithFrame:CGRectMake(0, 0, self.viewFacebook.frame.size.width, self.viewFacebook.frame.size.height) type:BButtonTypeFacebook style:BButtonStyleBootstrapV3];
    [btn setTitle:@"Share" forState:UIControlStateNormal];
    [btn addAwesomeIcon:FAIconFacebook beforeTitle:YES];
    [self.viewFacebook addSubview:btn];
    
    btn = [[BButton alloc] initWithFrame:CGRectMake(0, 0, self.viewTwitter.frame.size.width, self.viewTwitter.frame.size.height) type:BButtonTypeTwitter style:BButtonStyleBootstrapV3];
    [btn setTitle:@"Share" forState:UIControlStateNormal];
    [btn addAwesomeIcon:FAIconTwitter beforeTitle:YES];
    [self.viewTwitter addSubview:btn];
    
    btn = [[BButton alloc] initWithFrame:CGRectMake(0, 0, self.viewMail.frame.size.width, self.viewMail.frame.size.height) type:BButtonTypeInfo style:BButtonStyleBootstrapV3];
    [btn setTitle:@"Share" forState:UIControlStateNormal];
    [btn addAwesomeIcon:FAIconEnvelopeAlt beforeTitle:YES];
    [self.viewMail addSubview:btn];
    
    [btn addTarget:self action:@selector(onClickMail:) forControlEvents:UIControlEventTouchUpInside];
}

//Using NSDictionary for Add to Favorites

- (void) updateFavouriteButton
{
    if (!self.detailItem)
        return;
    
    NSDictionary *retrievedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"DicUrlKey"];

    // Set isFavourite to false
    BOOL isFavourite = FALSE;
    
    if ([retrievedDictionary objectForKey:self.detailItem.link]) {
        isFavourite = TRUE;
    }
    //IF isFavourite selected, fill the star
    if (isFavourite) {
        UIButton *favButton = [[UIButton alloc] init];
        favButton.frame=CGRectMake(0,0,30,30);
        [favButton setBackgroundImage:[UIImage imageNamed: @"star_done"] forState:UIControlStateNormal];
        [favButton addTarget:self action:@selector(onClickBookmarkRemove:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:favButton];
        // else clear the star selection
    } else {
        UIButton *favButton = [[UIButton alloc] init];
        favButton.frame=CGRectMake(0,0,30,30);
        [favButton setBackgroundImage:[UIImage imageNamed: @"star_ready"] forState:UIControlStateNormal];
        [favButton addTarget:self action:@selector(onClickBookmark:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:favButton];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickViewArticle:(id)sender {
    if (_detailItem && _detailItem.link) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: _detailItem.link]];
    }
}
- (IBAction)onClickMail:(id)sender {
    if (_detailItem) {
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
        if ([MFMailComposeViewController canSendMail]) {
            NSString *mailTitle = [NSString stringWithFormat:@"Check out: %@", _detailItem.title ? [_detailItem.title stringByConvertingHTMLToPlainText] : @"No Title"];
            NSString *emailBody = [NSString stringWithFormat:@"<html><body><p>This might interest you: %@</p><br /><a href=\"%@\">Read full article</a><br />%@",
                                   _detailItem.title ? [_detailItem.title stringByConvertingHTMLToPlainText] : @"No Title",
                                   _detailItem.link,
                                   _detailItem.summary];
            NSString *fromAddress = @"masoom.tulsiani@gmail.com";
            NSArray *addresses = [NSArray arrayWithObjects:fromAddress,nil];
            [mcvc setToRecipients:nil];
            [mcvc setBccRecipients:addresses];
            [mcvc setCcRecipients:addresses];
            [mcvc setSubject:mailTitle];
            [mcvc setMessageBody:emailBody isHTML:YES];
            mcvc.title = mailTitle;
            
            [self.navigationController presentViewController:mcvc animated:YES completion:^{
                
            }];
            // [mcvc addAttachmentData:ifAny mimeType:@"application/pdf" fileName:fileName];
        }
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //
    switch (result) {
        case MFMailComposeResultCancelled:  // Cancel
        {
            /*
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Cancel" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            
            [alert show];
             */
            break;
        }
        case MFMailComposeResultFailed: // fail
        {
            /*
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Failed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            
            [alert show];
            */
            break;
        }
        case MFMailComposeResultSent:   //Success
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Success" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            
            [alert show];
        }
        default:
            break;
    }
    // close modal
   // [self.navigationController dismissModalViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onClickBookmark:(id)sender
{
    NSLog(@"click fav");
    // add bookmark (Favorite)
    NSDictionary *retrievedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"DicUrlKey"];

    [retrievedDictionary setValue:@"1" forKey:self.detailItem.link];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateFavouriteButton];
}

- (IBAction)onClickBookmarkRemove:(id)sender {
    // remove bookmark (favorite)
    NSDictionary *retrievedDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"DicUrlKey"];
    NSMutableDictionary *copyDict = [[NSMutableDictionary alloc] initWithDictionary:retrievedDictionary];
    
    [copyDict removeObjectForKey:self.detailItem.link];
    
    [[NSUserDefaults standardUserDefaults] setObject:copyDict forKey:@"DicUrlKey"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateFavouriteButton];
}

@end
