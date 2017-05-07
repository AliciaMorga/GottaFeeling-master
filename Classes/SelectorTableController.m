//
//  SelectorTableController.m
//
//  Created by Sheldon Conaty on 25/05/2010.
//  Updated by Sheldon Conaty on 26/04/2011.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "SelectorTableController.h"
#import "PAImage.h"
#import "IconRegistry.h"

const CGFloat kStandardImageSize = 43.0f;


@implementation SelectorTableController

@synthesize labelFont=_labelFont, showIndex=_showIndex;

#pragma mark -
#pragma mark Private methods

- (NSArray *)letters {
	if (_letters == nil) {
		_letters = [[NSArray arrayWithObjects:
                     @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K",
                     @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V",
                     @"W", @"X", @"Y", @"Z", nil] retain];
	}
	return _letters;
}

// Returns an array of numbers, each element matches the letters array. The number storted at this index
// is the index of the starting label for that section.
- (NSArray *)sectionStartIndexes {
	if (_sectionStartIndexes == nil) {
		NSArray *letters = [self letters];
		_sectionStartIndexes = [[NSMutableArray arrayWithCapacity:[letters count]] retain];
		
		NSInteger startIndex = 0;
		[_sectionStartIndexes addObject:[NSNumber numberWithInt:0]];	// Letter 'A' starts at 0
		
		for (int i = 1; i < [letters count]; i++) {
			NSString *letterUpper = [letters objectAtIndex:i-1];
			NSString *letterLower = [letterUpper lowercaseString];
			
			for (NSString *label in _labels) {
				if ([label hasPrefix:letterLower] || [label hasPrefix:letterUpper])
					startIndex++;
			}
			
			[_sectionStartIndexes addObject:[NSNumber numberWithInt:startIndex]];
		}
	}
	
	return _sectionStartIndexes;
}

- (NSUInteger)flattenedIndexFromIndexPath:(NSIndexPath *)indexPath {
	if (_showIndex)
		return [[[self sectionStartIndexes] objectAtIndex:indexPath.section] intValue] + indexPath.row;
	else
		return indexPath.row;
}

- (void)startDownloadOfImage:(NSURL *)imageURL forIndexPath:(NSIndexPath *)indexPath {
	ImageDownloader *downloader = [_imageDownloadsInProgress objectForKey:indexPath];
	
	if (downloader == nil) {
		downloader = [[ImageDownloader alloc] init];
		downloader.delegate = self;
		downloader.key = indexPath;
		downloader.imageURL = imageURL;
		
		[_imageDownloadsInProgress setObject:downloader forKey:indexPath];
		
		[downloader startDownload];
		[downloader release];
	}
}

- (UIImage *)getCachedImageForIndexPath:(NSIndexPath *)indexPath {
	return [_cachedImages objectForKey:indexPath];
}

// Used in case the user scrolled into a set of cells that don't have their images yet
- (void)loadImagesForOnscreenRows {
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	
	for (NSIndexPath *indexPath in visiblePaths) {
		BOOL cellHasImageURL = ((_imageURLs) && ([_imageURLs objectAtIndex:[self flattenedIndexFromIndexPath:indexPath]] != [NSNull null]));
		BOOL imageNotCached  = ([self getCachedImageForIndexPath:indexPath] == nil);
		
		if (cellHasImageURL && imageNotCached) {	// Don't download if image already in cache
			NSURL *imageURL = [_imageURLs objectAtIndex:indexPath.row];
			[self startDownloadOfImage:imageURL forIndexPath:indexPath];
		}
	}
}


#pragma mark -
#pragma mark Public methods

- (id)initWithStyle:(UITableViewStyle)style labels:(NSArray *)labels details:(NSArray *)details
		  imageURLs:(NSArray *)imageURLs placeholderImageName:(NSString *)placeholderImageName
			   keys:(NSArray *)keys activeKey:(NSObject *)currentKey prompt:(NSString *)prompt target:(id)target action:(SEL)action
{
	if (self = [super initWithStyle:style]) {
		_labels = [labels retain];
		_details = [details retain];
		_imageURLs = [imageURLs retain];
		_keys = [keys retain];
		_target = [target retain];
		_action = action;
        
		_currentValueIndex = [_keys indexOfObject:currentKey];
		if (_currentValueIndex == NSNotFound) {
			_currentValueIndex = 0;
		}
        
		if (placeholderImageName) {
			UIImage *image = [UIImage imageNamed:placeholderImageName];
			if (image.size.height != kStandardImageSize)
				image = [image imageScaledToSize:CGSizeMake(kStandardImageSize, kStandardImageSize)];
			
			_placeholderImage = [image retain];
		}
		
		if (imageURLs) {
			_cachedImages = [[NSMutableDictionary dictionaryWithCapacity:[imageURLs count]] retain];	
		}
		
		self.title = prompt;
		
		_imageDownloadsInProgress = [[NSMutableDictionary dictionary] retain];
	}
	
	return self;
}

-(id)initWithStyle:(UITableViewStyle)style labels:(NSArray *)labels keys:(NSArray *)keys activeKey:(NSObject *)currentKey prompt:(NSString *)prompt target:(id)target action:(SEL)action {
    return [self initWithStyle:style labels:labels details:nil imageURLs:nil placeholderImageName:nil keys:keys activeKey:currentKey prompt:prompt target:target action:action];
}

- (id)activeKey {
	return [_keys objectAtIndex:_currentValueIndex];
}

- (void)setActiveKey:(NSObject *)newActiveKey {
	if ([newActiveKey isEqual:self.activeKey] == NO) {
		_currentValueIndex = [_keys indexOfObject:newActiveKey];
		[self.tableView reloadData];
	}
}


#pragma mark -
#pragma mark ImageDownloaderDelegate methods

- (void)imageDidLoad:(id)key image:(UIImage *)image {
	NSIndexPath *indexPath = (NSIndexPath *)key;
	
	ImageDownloader *downloader = [_imageDownloadsInProgress objectForKey:indexPath];
	
	if (downloader) {
		// Scale the image and cache image
		UIImage *scaledImage = [image imageScaledToSize:CGSizeMake(kStandardImageSize, kStandardImageSize)];
		[_cachedImages setObject:scaledImage forKey:indexPath];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.imageView.image = image;										// Note, cell not always found
		
		[_imageDownloadsInProgress removeObjectForKey:indexPath];			// Remove downloader
	}
}


#pragma mark -
#pragma mark UIScrollViewDelegate methods (deferred image loading)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate)
        [self loadImagesForOnscreenRows];			// Load images for all onscreen rows when scrolling is finished
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self loadImagesForOnscreenRows];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (_showIndex) ? [[self letters] count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_showIndex == NO)
		return [_labels count];
	
	// Find number of labels which start with this sections index letter
	
	NSString *letterUpper = [[self letters] objectAtIndex:section];
	NSString *letterLower = [letterUpper lowercaseString];
	NSInteger count = 0;
	for (NSString *label in _labels) {
		if ([label hasPrefix:letterLower] || [label hasPrefix:letterUpper])
			count++;
	}
	
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger labelIndex = [self flattenedIndexFromIndexPath:indexPath];
    
    BOOL cellHasDetailText = ((_details) && ([_details objectAtIndex:labelIndex] != [NSNull null]));
    BOOL cellHasImageURL   = ((_imageURLs) && ([_imageURLs objectAtIndex:labelIndex] != [NSNull null]));
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell_%@", cellHasDetailText ? @"subtitled" : @"default"];
	
    UITableViewCell *cell = nil;		// Note: always create new cell, sometimes cell cache would get confused and return cell with wrong style
	if (cellHasDetailText) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	} else {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    
    // Set up the cell...
	
	if (_labelFont)
		cell.textLabel.font = _labelFont;
	
	cell.textLabel.text = [_labels objectAtIndex:labelIndex];
	if (cellHasDetailText) {
		cell.detailTextLabel.text = [_details objectAtIndex:labelIndex];
	}
	
	if (cellHasImageURL) {
		UIImage *cachedImage = [self getCachedImageForIndexPath:indexPath];
        
		if (cachedImage) {
			cell.imageView.image = cachedImage;
		} else {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO) { // Defer new downloads until scrolling ends
				NSURL *imageURL = [_imageURLs objectAtIndex:labelIndex];
                [self startDownloadOfImage:imageURL forIndexPath:indexPath];
            }
            
            cell.imageView.image = _placeholderImage;
		}
	} else {
        cell.imageView.image = [IconRegistry iconForKey:[_labels objectAtIndex:labelIndex]];
	}
	
	if (_currentValueIndex == labelIndex)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (_showIndex) ? [[self letters] objectAtIndex:section] : nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return (_showIndex) ? [self letters] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return (_showIndex) ? [title characterAtIndex:0] - 'A' : 0;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_currentValueIndex = [self flattenedIndexFromIndexPath:indexPath];
	
	[_target performSelector:_action withObject:[_keys objectAtIndex:_currentValueIndex]];
	
    [self.tableView reloadData];

	if (self.navigationController)
		[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIViewController methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Terminate all pending downloads
    //    NSArray *allDownloads = [_imageDownloadsInProgress allValues];
    //    [allDownloads performSelector:@selector(cancelDownload)];
}


#pragma mark -
#pragma mark NSObject methods

- (void)dealloc {
	[_labels release];
	[_details release];
	[_imageURLs release];
	[_keys release];
	[_placeholderImage release];
	
	[_target release];
	
	[_cachedImages release];
	[_imageDownloadsInProgress release];
	
	[_letters release];
	[_sectionStartIndexes release];
    
	[_labelFont release];
	
    [super dealloc];
}

@end
