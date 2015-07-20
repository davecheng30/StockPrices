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
//   layer.backgroundColor = [NSColor greenColor].CGColor;
   layer.alignmentMode = kCAAlignmentCenter;
   layer.frame = [layer textBoundingRect];
   return layer;
}

@interface StockPricesViewController ()

@property(nonatomic, copy) NSArray* stockPrices;
@property(nonatomic) NSPoint originLocation;
@property(nonatomic) NSMutableArray* dateLayers;
@property(nonatomic) NSMutableArray* closePriceLayers;

@end

@implementation StockPricesViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.dateLayers = [NSMutableArray array];
   self.closePriceLayers = [NSMutableArray array];
   
   self.view.wantsLayer = YES;
   self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
   self.originLocation = NSMakePoint(60, 30);
   
//   CALayer* originLayer = [CALayer layer];
//   originLayer.backgroundColor = [NSColor redColor].CGColor;
//   originLayer.bounds = NSMakeRect(0,0, 5, 5);
//   originLayer.position = self.originLocation;
//   [self.view.layer addSublayer:originLayer];
   
   CALayer* xAxisLayer = [CALayer layer];
   xAxisLayer.backgroundColor = [NSColor blackColor].CGColor;
   xAxisLayer.frame = NSMakeRect(self.originLocation.x, self.originLocation.y, self.view.bounds.size.width, 1);
   [self.view.layer addSublayer:xAxisLayer];

   CALayer* yAxisLayer = [CALayer layer];
   yAxisLayer.backgroundColor = [NSColor blackColor].CGColor;
   yAxisLayer.frame = NSMakeRect(self.originLocation.x, self.originLocation.y, 1, self.view.bounds.size.height);
   [self.view.layer addSublayer:yAxisLayer];
}

-(void)loadStockPrices:(NSArray *)stockPrices
{
   self.stockPrices = stockPrices;
   [self updateView];
}

-(void)updateView
{
   [self createDateLayers];
   [self positionDateLayers];
   
   [self createClosePriceLayers];
   [self positionClosePriceLayers];
}

- (void)createDateLayers
{
   CALayer* rootLayer = self.view.layer;
   
   NSDate* firstDate = [self.stockPrices.firstObject date];
   NSDate* lastDate  = [self.stockPrices.lastObject date];
   
   // Create an x-axis label for each date in between (inclusive)
   NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateFormat:@"M/D"];
   NSTimeInterval secondsInOneDay = 60*60*24;
   for(NSDate* currentDate = firstDate; [currentDate isLessThanOrEqualTo:lastDate]; currentDate = [currentDate dateByAddingTimeInterval:secondsInOneDay] )
   {
      NSString* dateString = [dateFormatter stringFromDate:currentDate];
      CALayer* dateLayer = _textLayerWithString(dateString);
      dateLayer.anchorPoint = CGPointMake(0.5, 1.0);
      [rootLayer addSublayer:dateLayer];
      [self.dateLayers addObject:dateLayer];
   }
}

- (void)positionDateLayers
{
   NSUInteger numLayers = self.dateLayers.count;
   CGFloat totalWidth = self.view.frame.size.width - self.originLocation.x;
   CGFloat distanceBetweenLayers = totalWidth / (numLayers+1);
   int currX = self.originLocation.x + distanceBetweenLayers;
   for( CALayer* dateLayer in self.dateLayers )
   {
      dateLayer.position = CGPointMake(currX, self.originLocation.y - 2);
      currX += distanceBetweenLayers;
   }
}

-(NSRange)yAxisDollarRange
{
   NSParameterAssert(self.stockPrices.count > 0);
   CGFloat minClosePrice = CGFLOAT_MAX;
   CGFloat maxClosePrice = CGFLOAT_MIN;
   for( StockPrice* stockPrice in self.stockPrices )
   {
      CGFloat closePrice = stockPrice.closePrice;
      minClosePrice = MIN(minClosePrice, closePrice);
      maxClosePrice = MAX(maxClosePrice, closePrice);
   }
   int min = floor(minClosePrice);
   int max = ceil(maxClosePrice);
   return NSMakeRange(min, max-min);
}

- (void)createClosePriceLayers
{
   CALayer* rootLayer = self.view.layer;

   // Create a y-axis point for each integer dollar in this range
   NSRange yRange = [self yAxisDollarRange];
   for( NSUInteger i = yRange.location; i <= NSMaxRange(yRange); i++)
   {
      NSString* closePriceString = [NSString stringWithFormat:@"%ld", i];
      CALayer* closePriceLayer = _textLayerWithString(closePriceString);
      closePriceLayer.anchorPoint = CGPointMake(1.0, 0.5);
      [rootLayer addSublayer:closePriceLayer];
      [self.closePriceLayers addObject:closePriceLayer];
   }
}

- (void)positionClosePriceLayers
{
   NSUInteger numLayers = self.closePriceLayers.count;
   CGFloat totalHeight = self.view.frame.size.height - self.originLocation.y;
   CGFloat distanceBetweenLayers = totalHeight / (numLayers+1);
   
   int currY = self.originLocation.y + distanceBetweenLayers;
   for( CALayer* closePriceLayer in self.closePriceLayers )
   {
      closePriceLayer.position = CGPointMake(self.originLocation.x - 2, currY);
      currY += distanceBetweenLayers;
   }
}


@end
