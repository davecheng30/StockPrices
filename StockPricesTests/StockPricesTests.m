//
//  StockPricesTests.m
//  StockPricesTests
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "StockPricesParser.h"
#import "StockPrice.h"

@interface StockPricesTests : XCTestCase

@end

@implementation StockPricesTests

- (void)testJSONParsing
{
   NSURL* jsonURL = [[NSBundle mainBundle] URLForResource:@"stockprices" withExtension:@"json"];
   
   NSArray* stockPrices = [StockPricesParser stockPricesFromURL:jsonURL];
   XCTAssertEqual(5, stockPrices.count);
   XCTAssertEqualWithAccuracy(95.36,  ((StockPrice *)stockPrices[0]).closePrice, 0.001);
   XCTAssertEqualWithAccuracy(97.99,  ((StockPrice *)stockPrices[1]).closePrice, 0.001);
   XCTAssertEqualWithAccuracy(93.00,  ((StockPrice *)stockPrices[2]).closePrice, 0.001);
   XCTAssertEqualWithAccuracy(101.43, ((StockPrice *)stockPrices[3]).closePrice, 0.001);
   XCTAssertEqualWithAccuracy(102.66, ((StockPrice *)stockPrices[4]).closePrice, 0.001);
}

@end
