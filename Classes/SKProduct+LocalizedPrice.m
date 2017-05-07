//
//  SKProduct+LocalizedPrice.m
//  GottaFeeling
//
//  Created by Liam Hennessy on 08/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "SKProduct+LocalizedPrice.h"

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice {
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [numberFormatter setLocale:self.priceLocale];
  NSString *formattedString = [numberFormatter stringFromNumber:self.price];
  [numberFormatter release];
  return formattedString;
}

@end