//
//  StockPricesView.m
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import "StockPricesView.h"

@implementation StockPricesView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
   
   [[NSColor redColor] setFill];
   NSRectFill(dirtyRect);
    
    // Drawing code here.
}

@end
