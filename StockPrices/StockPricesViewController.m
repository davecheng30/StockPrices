//
//  StockPricesViewController.m
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import "StockPricesViewController.h"
#import "StockPrice.h"
#import "CATextLayer+TextBounds.h"
@import QuartzCore;

CALayer* _textLayerWithString(NSString* str)
{
   NSString* fontName = @"Helvetica";
   CGFloat fontSize = 14;
   NSFont* font = [NSFont fontWithName:fontName size:fontSize];
   CATextLayer* layer = [CATextLayer layer];
   layer.string = str;
   layer.font = (__bridge CTFontRef)font;
   layer.fontSize = fontSize;
   layer.foregroundColor = [NSColor blackColor].CGColor;
   layer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
   layer.backgroundColor = [NSColor greenColor].CGColor;
   layer.alignmentMode = kCAAlignmentCenter;
   layer.frame = [layer textBoundingRect];
   return layer;
}

@interface StockPricesViewController ()

@property(nonatomic, copy) NSArray* stockPrices;

@end

@implementation StockPricesViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.view.wantsLayer = YES;
}

-(void)loadStockPrices:(NSArray *)stockPrices
{
   self.stockPrices = stockPrices;
   [self updateView];
}

-(void)updateView
{
   CALayer* rootLayer = self.view.layer;

   NSDate* firstDate = [self.stockPrices.firstObject date];
   NSDate* lastDate  = [self.stockPrices.lastObject date];
   
   // Create an x-axis label for each date in between (inclusive)
   NSTimeInterval secondsInOneDay = 60*60*24;
   for(NSDate* currentDate = firstDate; [currentDate isLessThanOrEqualTo:lastDate]; currentDate = [currentDate dateByAddingTimeInterval:secondsInOneDay] )
   {
      NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"M/D"];
      NSString* dateString = [dateFormatter stringFromDate:currentDate];
//      NSLog(@"date = %@", dateString);
      
      CALayer* dateLayer = _textLayerWithString(dateString);
      [rootLayer addSublayer:dateLayer];
   }
}

@end
