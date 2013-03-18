//
//  ViewController.m
//  Demo
//
//  Copyright (c) 2012 metaio GmbH. All rights reserved.
//

#import "ViewController.h"
#import "ARELViewController.h"
#import "DetailViewController.h"

#import "Tutorial1/Tutorial1ViewController.h"
#import "Tutorial2/Tutorial2ViewController.h"
#import "Tutorial3/Tutorial3ViewController.h"
#import "Tutorial4/Tutorial4ViewController.h"
#import "Tutorial5/Tutorial5ViewController.h"
#import "Tutorial6/Tutorial6ViewController.h"
#import "Tutorial7/Tutorial7ViewController.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ViewController () {
    NSString *tutorialId;
    NSString *xibFile;
    NSString *arelConfigFile;
}
@end

@implementation ViewController
@synthesize tutorialsView;

- (void)viewWillAppear:(BOOL)animated {
    
    NSString *indexPath;
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        NSLog(@"Loading iOS 4 index");
        indexPath = [[NSBundle mainBundle] pathForResource:@"index-ios4" ofType:@"html" inDirectory:@"WebWrapper"];
    }
    else {
        NSLog(@"Loading iOS 5 index");
        indexPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"WebWrapper"];
    }

    NSURL *url = [NSURL fileURLWithPath:indexPath];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    [tutorialsView loadRequest:requestObj];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* theURL = [request mainDocumentURL];
    NSString* absoluteString = [theURL absoluteString];
    tutorialId = [[absoluteString componentsSeparatedByString:@"="] lastObject];
    
    if( [absoluteString hasPrefix:@"metaioSDKExample://"] )
    {
        if( tutorialId )
        {
            xibFile = [NSString stringWithFormat:@"Tutorial%@",tutorialId];
            if ([tutorialId isEqualToString:@"1"])
            {
                Tutorial1ViewController* tutorialViewController = [[Tutorial1ViewController alloc] initWithNibName:xibFile bundle:nil];
                tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:tutorialViewController animated:YES];
                //[tutorialViewController release];
            }
            else if ([tutorialId isEqualToString:@"2"])
            {
                Tutorial2ViewController* tutorialViewController = [[Tutorial2ViewController alloc] initWithNibName:xibFile bundle:nil];
                tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:tutorialViewController animated:YES];
            }
            else if ([tutorialId isEqualToString:@"3"])
            {
                Tutorial3ViewController* tutorialViewController = [[Tutorial3ViewController alloc] initWithNibName:xibFile bundle:nil];
                tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:tutorialViewController animated:YES];
            }
            else if ([tutorialId isEqualToString:@"4"])
            {
                Tutorial4ViewController* tutorialViewController = [[Tutorial4ViewController alloc] initWithNibName:xibFile bundle:nil];
                tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:tutorialViewController animated:YES];
            }
            else if ([tutorialId isEqualToString:@"5"])
            {
                Tutorial5ViewController* tutorialViewController = [[Tutorial5ViewController alloc] initWithNibName:xibFile bundle:nil];
                tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:tutorialViewController animated:YES];
            }
            else if ([tutorialId isEqualToString:@"6"])
            {
                Tutorial6ViewController* tutorialViewController = [[Tutorial6ViewController alloc] initWithNibName:xibFile bundle:nil];
                tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:tutorialViewController animated:YES];
            }
            else if ([tutorialId isEqualToString:@"7"])
            {
                Tutorial7ViewController* tutorialViewController = [[Tutorial7ViewController alloc] initWithNibName:xibFile bundle:nil];
                tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:tutorialViewController animated:YES];
            }
        }
        return NO;
    }
    else if( [absoluteString hasPrefix:@"metaioSDKExampleAREL://"] )
    {
        if (tutorialId)
        {
            arelConfigFile = [NSString stringWithFormat:@"arelConfig%@",tutorialId];
            NSString *arelConfigFilePath = [[NSBundle mainBundle] pathForResource:arelConfigFile ofType:@"xml"];
            NSLog(@"Will be loading AREL from %@",arelConfigFilePath);
            ARELViewController* tutorialViewController = [[ARELViewController alloc] initWithNibName:@"ARELViewController" bundle:nil instructions:arelConfigFilePath];
            tutorialViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
           [self presentModalViewController:tutorialViewController animated:YES];
                //[tutorialViewController release];
        }
        return NO;
    }
    else if( [[absoluteString lowercaseString] hasPrefix:@"doc://"] )
    {
        NSString* tutorialLink = [[absoluteString componentsSeparatedByString:@"url="] lastObject];
        if (tutorialLink)
        {
            NSLog(@"Tutorial Url =  %@",tutorialLink);
            DetailViewController* detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil link:tutorialLink];
            detailViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:detailViewController animated:YES];
            //[tutorialViewController release];
        }
        return NO;
    }
    else if( [[absoluteString lowercaseString] hasPrefix:@"http"] )
    {
        return YES;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    tutorialsView.delegate = self;
}

- (void)viewDidUnload
{
    [self setTutorialsView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
