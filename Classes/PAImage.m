//
//  PAImage.m
//
//  Created by Sheldon Conaty on 01/06/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "PAImage.h"


@implementation UIImage (PAImage)

// Returns image scaled to specified size. Returned UIImage is set to autorelease, make sure you retain if needed.
- (UIImage *)imageScaledToSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGRect imageRect = CGRectMake(0.0f, 0.0f, size.width, size.height);
	[self drawInRect:imageRect];
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return scaledImage;
}	

- (UIImage *)imageScaledToWidth:(CGFloat)targetWidth {
	CGFloat targetHeight = round(self.size.height * (targetWidth/self.size.width));
	return [self imageScaledToSize:CGSizeMake(targetWidth, targetHeight)];
}

- (UIImage *)imageScaledToHeight:(CGFloat)targetHeight {
	CGFloat targetWidth = round(self.size.width * (targetHeight/self.size.height));
	return [self imageScaledToSize:CGSizeMake(targetWidth, targetHeight)];
}

- (UIImage *)imageWithTopPadding:(CGFloat)topPadding {
	CGSize newSize = CGSizeMake(self.size.width, self.size.height+topPadding);
	UIGraphicsBeginImageContext(newSize);
	
	CGRect imageRect = CGRectMake(0.0f, topPadding, self.size.width, self.size.height);
	[self drawInRect:imageRect];
	UIImage* paddedImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return paddedImage;
}

@end
