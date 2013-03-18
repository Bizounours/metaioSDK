//
//  DetailViewController.h
//  Example
//
//  Copyright (c) 2012 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *detailView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)url;
- (IBAction)onBtnClosePushed:(id)sender;

@end
