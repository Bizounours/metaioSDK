//
//  DetailViewController.m
//  Example
//
//  Copyright (c) 2012 metaio GmbH. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
{
    NSString *detaillUrl;
}

@end

@implementation DetailViewController
@synthesize detailView;
@synthesize closeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil link:(NSString *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        detaillUrl = [[NSString alloc] initWithString:url];
    }
    return self;
}

- (IBAction)onBtnClosePushed:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"Tutorial url to be loaded = %@",detaillUrl);
    NSURL *url = [NSURL URLWithString:detaillUrl];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [detailView loadRequest:requestObj];
}

- (void)viewDidUnload
{
    [self setDetailView:nil];
    [self setCloseButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
