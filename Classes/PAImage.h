//
//  PAImage.h
//
//  Created by Sheldon Conaty on 01/06/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (PAImage)

- (UIImage *)imageScaledToSize:(CGSize)size;
- (UIImage *)imageScaledToWidth:(CGFloat)targetWidth;
- (UIImage *)imageScaledToHeight:(CGFloat)targetHeight;
- (UIImage *)imageWithTopPadding:(CGFloat)topPadding;

@end
