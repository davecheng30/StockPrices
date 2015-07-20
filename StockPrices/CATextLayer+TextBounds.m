//
//  CATextLayer+TextBounds.m
//  StockPrices
//
//  Created by David Cheng on 7/19/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import "CATextLayer+TextBounds.h"
@import Cocoa;

@implementation CATextLayer (TextBounds)

-(NSRect)textBoundingRect
{
   NSString* str = self.string;
   NSFont* font = (__bridge NSFont *)self.font;
   NSDictionary* attributes = @{ NSFontAttributeName : font };
   NSRect boundingRect = [str boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes];
   //   NSLog(@"boundingRect = %@", NSStringFromRect(boundingRect));
   return boundingRect;
}


@end
