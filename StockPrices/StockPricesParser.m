//
//  StockPricesParser.m
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import "StockPricesParser.h"
#import "StockPrice.h"

static NSArray* _findStockDataJSONArrayInRootJSONDict(id rootJSONDictObject)
{
   if ( [rootJSONDictObject isKindOfClass:[NSDictionary class]] )
   {
      NSDictionary* rootJSONDict = rootJSONDictObject;
      id stockDataArrayObject = rootJSONDict[@"stockdata"];
      if ( [stockDataArrayObject isKindOfClass:[NSArray class]] )
      {
         NSArray* stockDataArray = stockDataArrayObject;
         
         // Verify that each item in the array is an NSDictionary
         for( id stockDataObject in stockDataArray )
         {
            if ( ![stockDataObject isKindOfClass:[NSDictionary class]] )
               return nil;
         }
         
         return stockDataArray;
      }
   }
   return nil;
}

@implementation StockPricesParser

+(NSArray *)stockPricesFromURL:(NSURL *)url
{
   if ( !url )
      return nil;

   // TODO: Could do this asynchronously for remote URLs
   NSData* jsonData = [NSData dataWithContentsOfURL:url];
   
   NSError* error = nil;
   id object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
   if ( error )
   {
      NSLog(@"Error parsing url = %@, error = %@", url, error);
      return nil;
   }
   
   NSMutableArray* ret = [NSMutableArray array];
   NSArray* stockPriceJSONArray = _findStockDataJSONArrayInRootJSONDict(object);
   if ( !stockPriceJSONArray )
   {
      NSLog(@"Could not parse JSON");
      return nil;
   }
   
   for( NSDictionary* stockPriceJSON in stockPriceJSONArray )
   {
      StockPrice* stockPrice = [[StockPrice alloc] initWithJSONDictionary:stockPriceJSON];
      if ( stockPrice )
      {
         [ret addObject:stockPrice];
      }
   }
   return ret;
}

@end
