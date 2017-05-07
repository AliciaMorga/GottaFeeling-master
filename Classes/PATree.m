//
//  PATree.m
//
//  Created by Denis on 24/08/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import "PATree.h"
#import "CSVParser.h"

@interface PATree (PrivateMethods)
- (NSArray *)childrenForSection:(NSInteger)sections;
- (BOOL)isNodeValid:(PATree *)node;
- (NSString *)matchKeys:(NSArray *)keys guess:(NSString *)guess;
@end

@implementation PATree
@synthesize delegate, indexKey;

+ (id)treeWithDictionary:(NSDictionary *)dict {
    return [[[PATree alloc] initWithDictionary:dict] autorelease];
}

// Memory management

- (id)init {
    if ((self = [super init])) {
        attributes = [[NSMutableDictionary alloc] init];
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if ((self = [super init])) {
        attributes = [[NSMutableDictionary dictionaryWithDictionary:dict] retain];
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ (%d children)", [attributes objectForKey:KEY_TITLE], [children count]];
}

- (void)dealloc {    
    [attributes release];
    [children release];
    [sections release];
    [searchResults release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Importers / Data Access

- (NSDictionary *)attributes {
    return attributes;
}

- (NSArray *)children {
    return children;
}

- (BOOL)processImportAttributes:(NSMutableDictionary *)dict {
    if (titleKey && [dict valueForKey:titleKey])
        [dict setValue:[dict valueForKey:titleKey] forKey:KEY_TITLE];
    return YES;
}

- (BOOL)loadCSV:(NSString *)path error:(NSError **)error title:(NSString *)title {
    titleKey = title;
    return [self loadCSV:path error:error target:self selector:@selector(processImportAttributes:)];
}

- (BOOL)loadCSV:(NSString *)path error:(NSError **)error target:(id)target selector:(SEL)selector {
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:error];
    if (!fileContents)
        fileContents = [NSString stringWithContentsOfFile:path encoding:NSWindowsCP1252StringEncoding error:error];
	if (!fileContents) {
        NSLog(@"CSVError: Unable to read CSV file: %@", *error);
		return NO;
    }
    
	NSArray *lines = [fileContents csvRows];
	if ([lines count] == 0) {
		NSString *err = @"CSV file must include at least a header row";
		NSLog(@"CSVError: %@", err);
		if (error)
			*error = [NSError errorWithDomain:err code:1 userInfo:nil];
		return NO;
	}
    
	NSArray *keys = [lines objectAtIndex:0];
    titleKey = [self matchKeys:keys guess:titleKey];
	for (int i=1;i<[lines count];i++) {
		NSMutableDictionary *node = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
		NSArray *vals = [lines objectAtIndex:i];
		for (int j=0;j<MIN([keys count], [vals count]);j++)
			[node setValue:[vals objectAtIndex:j] forKey:[keys objectAtIndex:j]];
        [node setValue:@"WebViewController" forKey:KEY_VIEW];
        if (target) {
            if ([target performSelector:selector withObject:node])
                [self addNode:node];
            
        } else {
            [self addNode:node];            
        }
        if (titleKey)
            [node setValue:[node objectForKey:titleKey] forKey:KEY_TITLE];            
    }
    
    return YES;
}

- (PATree *)addNode:(NSDictionary *)attrs {
    NSString *section = [attributes objectForKey:KEY_SECTION];
    if (section != nil) {
        // todo
        return nil;
    } else {
        PATree *newNode = [PATree treeWithDictionary:attrs];
        if ([self isNodeValid:newNode]) {
            [children addObject:newNode];
            return newNode;
        } else {
            return nil;
        }
    }
}

- (void)addTree:(PATree *)tree {
    NSString *section = [attributes objectForKey:KEY_SECTION];
    if (section != nil) {
        // todo
        return;
    } else {
        if ([self isNodeValid:tree]) {
            [children addObject:tree];
        }
    }    
}

- (void)addTitles:(NSString *) firstTitle, ... {
    NSString *eachTitle;
    va_list argumentList;
    if (firstTitle) {
        [self addNode:[NSDictionary dictionaryWithObjectsAndKeys:firstTitle, KEY_TITLE, nil]];
        va_start(argumentList, firstTitle);
        while (eachTitle = va_arg(argumentList, NSString*))
            [self addNode:[NSDictionary dictionaryWithObjectsAndKeys:eachTitle, KEY_TITLE, nil]];
        va_end(argumentList);
    }    
}

- (PATree *)nodeAtIndexPath:(NSIndexPath *)indexPath {
    if (searchResults)
        return [searchResults objectAtIndex:indexPath.row];
        
    NSArray *grandchildren = [self childrenForSection:indexPath.section];
    if (indexPath.row >= [grandchildren count])
        return nil;
    return [grandchildren objectAtIndex:indexPath.row];
}

- (id)valueForKey:(NSString *)key {
    return [attributes valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [attributes setValue:value forKey:key];
}

// valueForKey: and setValue:forKey:

#pragma mark -
#pragma mark Restructuring

- (NSArray *)categorizeBy:(NSString *)groupKey {
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:1];
    for (PATree *node in children) {
        NSString *groupVal = [node valueForKey:groupKey];
        BOOL found = NO;
        for (PATree *group in groups) {
            if ([groupVal compare:[group valueForKey:groupKey] options:NSCaseInsensitiveSearch] == 0) {
                [group addTree:node];
                found = YES;
                break;
            }
        }
        if (!found) {
            PATree *newGroup = [[[PATree alloc] initWithDictionary:[node attributes]] autorelease];
            [newGroup setValue:groupVal forKey:KEY_TITLE];
            [newGroup setValue:nil forKey:KEY_VIEW];
            [newGroup addTree:node];
            [groups addObject:newGroup];
        }
    }
    return groups;
}

- (void)extractSectionsBy:(NSString *)sectionKey {
    if (sections)
        [sections release];
    if (sectionKey)
        sections = [[self categorizeBy:sectionKey] retain];
    else
        sections = nil;
}

// Create an extra level where all children what share a common grouping key
// are grouped together under a common parent.
- (void)groupBy:(NSString *)groupKey {
    // TODO: moan if multiple sections exist (not handled yet)
    NSArray *groups = [self categorizeBy:groupKey];
    [children release];
    children = [groups retain];
}

- (void)sortByKey:(NSString *)attr {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:attr ascending:YES] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [children sortedArrayUsingDescriptors:sortDescriptors];
    [children release];
    children = [sortedArray retain];
}

- (void)sortByKeys:(NSArray *)attrs {
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:[attrs count]];
    for (NSString *attr in attrs) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:attr ascending:YES] autorelease];
        [sortDescriptors addObject:sortDescriptor];
    }
    NSArray *sortedArray;
    sortedArray = [children sortedArrayUsingDescriptors:sortDescriptors];
    [children release];
    children = [sortedArray retain];
}

- (void)removeLocalizedDuplicates {
    NSMutableArray *uniques = [NSMutableArray arrayWithCapacity:1];
    for (PATree *node in children) {
        NSString *style = [node valueForKey:@"Category"];
        NSString *title = NSLocalizedString([node valueForKey:KEY_TITLE], nil);
        BOOL duplicate = NO;
        for (PATree *existing in uniques) {
            if ([title isEqualToString:NSLocalizedString([existing valueForKey:KEY_TITLE], nil)] &&
                [style isEqualToString:[existing valueForKey:@"Category"]]) {
                duplicate = YES;
//                NSLog(@"Removing %@ - %@ from %@", title, NSLocalizedString([existing valueForKey:KEY_TITLE], nil), style);
                break;
            }
        }
        if (!duplicate) {
            [uniques addObject:node];
        }        
    }
    [children release];
    children = [uniques retain];
}

- (void)setSearchString:(NSString *)searchString {
    if (searchResults) {
        [searchResults release];
        searchResults = nil;
    }
    if (searchString && [searchString length]) {
        searchResults = [[NSMutableArray alloc] initWithCapacity:1];
        for (PATree *possible in children) {
            BOOL match;
            if ([delegate respondsToSelector:@selector(tree:matchesSearch:)]) {
                match = [delegate tree:possible matchesSearch:searchString];
            } else {   
                NSRange range = [[possible valueForKey:KEY_TITLE] rangeOfString:searchString options:NSCaseInsensitiveSearch];
                match = (range.location != NSNotFound);
            }
            if (match)
                [searchResults addObject:possible];
        }
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (searchResults || sections == nil)
        return 1;
    else
        return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searchResults)
        return [searchResults count];
        
    NSArray *grandchildren = [self childrenForSection:section];
    return [grandchildren count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (searchResults || sections == nil)
        return nil;

    PATree *sect = [sections objectAtIndex:section];
    if ([delegate respondsToSelector:@selector(tree:titleForSection:)]) {
        return [delegate tree:self titleForSection:section];
    } else {   
        return [sect valueForKey:KEY_TITLE];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (searchResults || sections == nil || indexKey == nil)
        return nil;
    
    NSMutableArray *index = [NSMutableArray arrayWithCapacity:[sections count]];
    [index addObject:@"{search}"];
    for (PATree *node in sections) {
        [index addObject:[node valueForKey:indexKey]];
    }
    
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PATree *node = nil;
    if (searchResults)
        node = [searchResults objectAtIndex:indexPath.row];
    else
        node = [self nodeAtIndexPath:indexPath];
    if (node == nil)
        return nil;
    
    NSString *cellIdentifier = [node valueForKey:KEY_STYLE];
    if (cellIdentifier == nil)
        cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if ([delegate respondsToSelector:@selector(tree:createCellForIdentifier:)]) {
            cell = [delegate tree:node createCellForIdentifier:cellIdentifier];
        } else {   
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        }
    }

    cell.textLabel.text = [node valueForKey:KEY_TITLE];
    cell.detailTextLabel.text = [node valueForKey:KEY_SUBTITLE];
    if ([node valueForKey:KEY_ICON])
        cell.imageView.image = [UIImage imageNamed:[node valueForKey:KEY_ICON]];
    if ([delegate respondsToSelector:@selector(tree:configureCell:)])
        [delegate tree:node configureCell:cell];

    return cell;
}

// Private helpers
    
- (NSArray *)childrenForSection:(NSInteger)section {
    if (sections != nil) {
        if (section >= [sections count])
            return nil;
        PATree *sect = [sections objectAtIndex:section];
        return [sect children];
    } else {
        if (section > 0)
            return nil;
        return children;
    }
}

// Sanity check before adding node:
// * Check for non-blank title
- (BOOL)isNodeValid:(PATree *)node {
    NSString *title = [node valueForKey:KEY_TITLE];
    if (title == nil)
        return NO;
    title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return ([title length] > 0);
}

// Find a key that matches a guess (ignoring case and leading/trailing spaces
- (NSString *)matchKeys:(NSArray *)keys guess:(NSString *)guess {
    for (NSString *key in keys) {
        if ([key compare:guess options:NSCaseInsensitiveSearch] == 0)
            return key;
        NSString *trimmedKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimmedKey compare:guess options:NSCaseInsensitiveSearch] == 0)
            return key;
    }
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
                atIndex:(NSInteger)index {
    if (index == 0) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index -1;
}

@end
