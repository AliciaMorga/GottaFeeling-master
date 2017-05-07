//
//  ImageDownloader.m
//
//  Created by Sheldon Conaty on 01/06/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "ImageDownloader.h"


@implementation ImageDownloader

@synthesize key, delegate, imageURL;
@synthesize activeDownload, imageConnection;


#pragma mark -
#pragma mark Public methods

- (void)startDownload {
    self.activeDownload = [NSMutableData data];
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:imageURL] delegate:self];
    self.imageConnection = conn;
    [conn release];
}

- (void)cancelDownload {
	[self.imageConnection cancel];
	self.imageConnection = nil;
	self.activeDownload = nil;
}


#pragma mark -
#pragma mark NSURLConnectionDelegate methods (download support)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"ImageDownloader connection error: %@", error);
    self.activeDownload = nil;						// Clear the activeDownload property to allow later attempts
    self.imageConnection = nil;						// Release the connection now that it's finished
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    self.activeDownload = nil;
    self.imageConnection = nil;						// Release the connection now that it's finished
	
    [delegate imageDidLoad:key image:image];		// Call delegate and tell it that image is ready
    
    [image release];
}


#pragma mark NSObject methods

- (void)dealloc
{
    [key release];
	[imageURL release];
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

@end
