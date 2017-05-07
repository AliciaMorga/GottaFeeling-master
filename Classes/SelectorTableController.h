//
//  SelectorTableController.h
//
//  Created by Sheldon Conaty on 25/05/2010.
//  Updated by Sheldon Conaty on 26/04/2011.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"


@interface SelectorTableController : UITableViewController <UIScrollViewDelegate, ImageDownloaderDelegate> {
	NSArray *_labels;
	NSArray *_details;
	NSArray *_imageURLs;
	NSArray *_keys;
	UIImage *_placeholderImage;
	
	id _target;
	SEL _action;
	
	BOOL _showIndex;
	
	NSInteger _currentValueIndex;
	
	NSMutableDictionary *_cachedImages;
	NSMutableDictionary *_imageDownloadsInProgress;	// Set of ImageDownloader objects
	
	UIFont *_labelFont;								// If supplied this font will be used when rendering cell labels
	
	NSArray *_letters;								// Private: should only be accessed via factory method
	NSMutableArray *_sectionStartIndexes;			// Private: should only be accessed via factory method
}

@property (nonatomic, retain) UIFont *labelFont;
@property (nonatomic, assign) NSObject *activeKey;

@property (nonatomic, assign) BOOL showIndex;		// Shows A-Z quick navigation index, similar to contacts app. Assumes labels are sorted and table is plain

// Supply an array of strings (labels) which are to be displayed. When the user has selected a label the corresponding key is passed to the
// target action
//
// If the SelectorTableController has been added to a navigation stack it will automatically pop itself off when a value has been selected
// otherwise it is the target actions responsibility to close the SelectorTableController.
//
-(id)initWithStyle:(UITableViewStyle)style labels:(NSArray *)labels details:(NSArray *)details imageURLs:(NSArray *)imageURLs placeholderImageName:(NSString *)placeholderImageName keys:(NSArray *)keys activeKey:(NSObject *)currentKey prompt:(NSString *)prompt target:(id)target action:(SEL)action;

-(id)initWithStyle:(UITableViewStyle)style labels:(NSArray *)labels keys:(NSArray *)keys activeKey:(NSObject *)currentKey prompt:(NSString *)prompt target:(id)target action:(SEL)action;

@end
