//
//  ImageDownloader.h
//
//  Created by Sheldon Conaty on 01/06/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSObject
{
	id key;											// Generally a NSIndexPath for the table row
    id<ImageDownloaderDelegate> delegate;
    NSURL *imageURL;								// Remote URL from which to load image
	
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) id key;								// Object which callers uses to identify image
@property (nonatomic, assign) id <ImageDownloaderDelegate> delegate;
@property (nonatomic, retain) NSURL *imageURL;

@property (nonatomic, retain) NSMutableData *activeDownload;		// Data for images as it is being downloaded
@property (nonatomic, retain) NSURLConnection *imageConnection;		// Connection used to download image

- (void)startDownload;
- (void)cancelDownload;

@end


@protocol ImageDownloaderDelegate 

- (void)imageDidLoad:(id)key image:(UIImage *)image;

@end