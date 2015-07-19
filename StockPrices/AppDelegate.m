//
//  AppDelegate.m
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import "AppDelegate.h"
#import "StockPricesViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *stockPricesContainerView;
@property (nonatomic) StockPricesViewController* stockPricesViewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   self.stockPricesViewController = [[StockPricesViewController alloc] init];
   
   NSView* parentView = self.stockPricesContainerView;
   NSView* childView = self.stockPricesViewController.view;
   [parentView addSubview:childView];
   
   childView.translatesAutoresizingMaskIntoConstraints = NO;
   
   NSDictionary* views = NSDictionaryOfVariableBindings(parentView, childView);
   [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|" options:0 metrics:nil views:views]];
   [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|" options:0 metrics:nil views:views]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
   // Insert code here to tear down your application
}

@end
