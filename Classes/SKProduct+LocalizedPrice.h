//
//  SKProduct+LocalizedPrice.h
//  GottaFeeling
//
//  Created by Liam Hennessy on 08/12/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end