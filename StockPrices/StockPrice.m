//
//  StockPrice.m
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import "StockPrice.h"

NSDate* _dateFromJSONDateString(NSString* dateString)
{
   NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateFormat:@"YYYY-MM-DD"];
   return [dateFormatter dateFromString:dateString];
}


@implementation StockPrice

-(instancetype)initWithDate:(NSDate *)date close:(CGFloat)close
{
   self = [super init];
   if ( self )
   {
      _date = date;
      _close = close;
   }
   return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary
{
   CGFloat close = [jsonDictionary[@"close"] floatValue];
   NSDate* date = _dateFromJSONDateString(jsonDictionary[@"date"]);
   return [self initWithDate:date close:close];
}
@end
