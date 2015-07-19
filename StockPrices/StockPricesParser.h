//
//  StockPricesParser.h
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockPricesParser : NSObject

+(NSArray *)stockPricesFromURL:(NSURL *)url;

@end
