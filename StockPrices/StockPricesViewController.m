//
//  StockPricesViewController.m
//  StockPrices
//
//  Created by David Cheng on 7/18/15.
//  Copyright (c) 2015 Dave Cheng. All rights reserved.
//

#import "StockPricesViewController.h"

@interface StockPricesViewController ()

@property(nonatomic, copy) NSArray* stockPrices;

@end

@implementation StockPricesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)loadStockPrices:(NSArray *)stockPrices
{
   self.stockPrices = stockPrices;
   
   [self updateView];
}

-(void)updateView
{
   
}

@end
