//
//  StockPrice.h
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockPrice : NSObject

@property (nonatomic) NSDate* date;
@property (nonatomic) CGFloat close;

-(instancetype)initWithDate:(NSDate *)date close:(CGFloat)close NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@end
