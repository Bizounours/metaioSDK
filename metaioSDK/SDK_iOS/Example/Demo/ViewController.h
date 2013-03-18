//
//  ViewController.h
//  Demo
//
//  Copyright (c) 2012 metaio GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIWebViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *tutorialsView;

@end
