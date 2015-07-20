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

static const NSTimeInterval s_secondsInOneDay = 60*60*24;

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

@property(nonatomic) CALayer* xAxisLayer;
@property(nonatomic) CALayer* yAxisLayer;

@property(nonatomic) NSMutableArray* dateLayers;
@property(nonatomic) NSMutableArray* closePriceLayers;
@property(nonatomic) NSMutableArray* closePriceLineLayers;
@property(nonatomic) CAShapeLayer* graphLayer;

@property(nonatomic) CGFloat xStep;
@property(nonatomic) CGFloat yStep;

@property(nonatomic) NSDate* firstDate;
@property(nonatomic) NSDate* lastDate;
@property(nonatomic) NSRange priceRange;

@end

@implementation StockPricesViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.dateLayers = [NSMutableArray array];
   self.closePriceLayers = [NSMutableArray array];
   self.closePriceLineLayers = [NSMutableArray array];
   
   self.view.wantsLayer = YES;
   self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
   self.originLocation = NSMakePoint(60, 30);
}

-(void)loadStockPrices:(NSArray *)stockPrices
{
   self.stockPrices = stockPrices;
   [self updateView];
}

-(void)updateView
{
   [self removeExistingLayers];
   
   // x and y axis lines
   [self createAxesLayers];
   
   // create and position date labels on the x-axis
   [self createDateLayers];
   [self positionDateLayers];
   
   // create and position close price labels on the y-axis
   [self createClosePriceLayers];
   [self positionClosePriceLayers];
   
   // Create the actual plotted graph layer
   [self createGraphLayer];
   
   // Do some fancy animations
   [self fadeInAxesAndLabels];
   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      
      [self animateInGraphLayer];
   });
}

-(void)removeExistingLayers
{
   NSArray* layers = [[self.dateLayers arrayByAddingObjectsFromArray:self.closePriceLayers] arrayByAddingObjectsFromArray:self.closePriceLineLayers];
   if( self.xAxisLayer )
   {
      layers = [layers arrayByAddingObject:self.xAxisLayer];
   }
   
   if( self.yAxisLayer )
   {
      layers = [layers arrayByAddingObject:self.yAxisLayer];
   }

   if( self.graphLayer )
   {
      layers = [layers arrayByAddingObject:self.graphLayer];
   }

   [layers enumerateObjectsUsingBlock:^(CALayer* layer, NSUInteger idx, BOOL *stop) {
      [layer removeFromSuperlayer];
   }];
   
   self.xAxisLayer = nil;
   self.yAxisLayer = nil;
   self.graphLayer = nil;
   [self.dateLayers removeAllObjects];
   [self.closePriceLayers removeAllObjects];
   [self.closePriceLineLayers removeAllObjects];
}

-(void)createAxesLayers
{
   self.xAxisLayer = [CALayer layer];
   self.xAxisLayer.backgroundColor = [NSColor blackColor].CGColor;
   self.xAxisLayer.frame = NSMakeRect(self.originLocation.x, self.originLocation.y, self.view.bounds.size.width, 1);
   [self.view.layer addSublayer:self.xAxisLayer];
   
   self.yAxisLayer = [CALayer layer];
   self.yAxisLayer.backgroundColor = [NSColor blackColor].CGColor;
   self.yAxisLayer.frame = NSMakeRect(self.originLocation.x, self.originLocation.y, 1, self.view.bounds.size.height);
   [self.view.layer addSublayer:self.yAxisLayer];
}

- (void)createDateLayers
{
   CALayer* rootLayer = self.view.layer;
   
   self.firstDate = [self.stockPrices.firstObject date];
   self.lastDate  = [self.stockPrices.lastObject date];
   
   // Create an x-axis label for each date in between (inclusive) to handle potential gaps between dates
   // so we always have an even interval between dates
   NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateFormat:@"M/d"];
   for(NSDate* currentDate = self.firstDate; [currentDate isLessThanOrEqualTo:self.lastDate]; currentDate = [currentDate dateByAddingTimeInterval:s_secondsInOneDay] )
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
   self.xStep = totalWidth / (numLayers+1);
   int currX = self.originLocation.x + self.xStep;
   for( CALayer* dateLayer in self.dateLayers )
   {
      dateLayer.position = CGPointMake(currX, self.originLocation.y - 2);
      currX += self.xStep;
   }
}

-(NSRange)calculateYAxisDollarRange
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
   self.priceRange = [self calculateYAxisDollarRange];
   for( NSUInteger i = self.priceRange.location; i <= NSMaxRange(self.priceRange); i++)
   {
      NSString* closePriceString = [NSString stringWithFormat:@"$%ld", i];
      CALayer* closePriceLayer = _textLayerWithString(closePriceString);
      closePriceLayer.anchorPoint = CGPointMake(1.0, 0.5);
      [rootLayer addSublayer:closePriceLayer];
      [self.closePriceLayers addObject:closePriceLayer];
      
      CALayer* closePriceLineLayer = [CALayer layer];
      closePriceLineLayer.frame = CGRectMake(0, 0, self.view.frame.size.width - self.originLocation.x, 1);
      closePriceLineLayer.backgroundColor = [NSColor lightGrayColor].CGColor;
      closePriceLineLayer.anchorPoint = CGPointMake(0.0, 0.5);
      [rootLayer addSublayer:closePriceLineLayer];
      [self.closePriceLineLayers addObject:closePriceLineLayer];
   }
}

- (void)positionClosePriceLayers
{
   NSUInteger numLayers = self.closePriceLayers.count;
   CGFloat totalHeight = self.view.frame.size.height - self.originLocation.y;
   self.yStep = totalHeight / (numLayers+1);
   
   int currY = self.originLocation.y + self.yStep;
   for( CALayer* closePriceLayer in self.closePriceLayers )
   {
      closePriceLayer.position = CGPointMake(self.originLocation.x - 2, currY);
      currY += self.yStep;
   }

   currY = self.originLocation.y + self.yStep;
   for( CALayer* closePriceLineLayer in self.closePriceLineLayers )
   {
      closePriceLineLayer.position = CGPointMake(self.originLocation.x, currY);
      currY += self.yStep;
   }
}

- (NSPoint)pointForStockPrice:(StockPrice *)stockPrice
{
   NSTimeInterval secondsSinceFirstDate = [stockPrice.date timeIntervalSinceDate:self.firstDate];
   int numXSteps = secondsSinceFirstDate / s_secondsInOneDay;
   
   CGFloat priceOffsetFromLowestPrice = stockPrice.closePrice - self.priceRange.location;
   return NSMakePoint(self.originLocation.x + self.xStep + numXSteps*self.xStep,
                      self.originLocation.y + self.yStep + priceOffsetFromLowestPrice*self.yStep);
}

- (CGPathRef)createPathForFlatGraph
{
   BOOL firstPoint = YES;
   CGMutablePathRef path = CGPathCreateMutable();
   for( StockPrice* stockPrice in self.stockPrices )
   {
      NSPoint pt = [self pointForStockPrice:stockPrice];
      pt.y = self.originLocation.y;
      if ( firstPoint )
      {
         CGPathMoveToPoint(path, NULL, pt.x, pt.y);
         firstPoint = NO;
      }
      else
      {
         CGPathAddLineToPoint(path, NULL, pt.x, pt.y);
      }
   }
   return path;
}

- (CGPathRef)createPathForGraph
{
   BOOL firstPoint = YES;
   CGMutablePathRef path = CGPathCreateMutable();
   for( StockPrice* stockPrice in self.stockPrices )
   {
      NSPoint pt = [self pointForStockPrice:stockPrice];
      if ( firstPoint )
      {
         CGPathMoveToPoint(path, NULL, pt.x, pt.y);
         firstPoint = NO;
      }
      else
      {
         CGPathAddLineToPoint(path, NULL, pt.x, pt.y);
      }
   }
   return path;
}

- (void)createGraphLayer
{
   self.graphLayer = [CAShapeLayer layer];
   self.graphLayer.frame = self.view.bounds;
   self.graphLayer.lineWidth = 1.0f;
   self.graphLayer.strokeColor = [NSColor blackColor].CGColor;
   self.graphLayer.fillColor = nil;
   CGPathRef path = [self createPathForFlatGraph];
   self.graphLayer.path = path;
   CGPathRelease(path);
   
   [self.view.layer addSublayer:self.graphLayer];
}

- (void)animateInGraphLayer
{
   CGPathRef flatPath = [self createPathForFlatGraph];
   CGPathRef graphPath = [self createPathForGraph];
   
   CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
   pathAnimation.duration = 1.0f;
   pathAnimation.fromValue = (__bridge id)flatPath;
   pathAnimation.toValue = (__bridge id)graphPath;
   pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
   [self.graphLayer addAnimation:pathAnimation forKey:@"path"];
   self.graphLayer.path = graphPath;
   
   CGPathRelease(flatPath);
   CGPathRelease(graphPath);
}

- (void)fadeInAxesAndLabels
{
   NSArray* layers = [self.dateLayers arrayByAddingObjectsFromArray:self.closePriceLayers];
   layers = [layers arrayByAddingObjectsFromArray:@[self.xAxisLayer, self.yAxisLayer]];
   for( CALayer* layer in layers )
   {
      CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
      anim.duration = 0.5f;
      anim.fromValue = @0.0;
      anim.toValue = @1.0;
      [layer addAnimation:anim forKey:@"opacity"];
   }
   
   for( CALayer* closePriceLineLayer in self.closePriceLineLayers )
   {
      CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"bounds"];
      anim.duration = 1.0f;
      anim.fromValue = [NSValue valueWithRect:NSZeroRect];
      anim.toValue   = [NSValue valueWithRect:closePriceLineLayer.bounds];
      anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
      [closePriceLineLayer addAnimation:anim forKey:@"bounds"];
   }
}

@end
