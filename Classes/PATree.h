//
//  PATree.h
//
//  Created by Denis on 24/08/2010.
//  Copyright (c) 2010 Peer Assembly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSKeyValueCoding.h>

#define KEY_SECTION     @"_section"
#define KEY_SECTIONS    @"_sections"
#define KEY_SUBTITLE    @"_subtitle"
#define KEY_TITLE       @"_title"
#define KEY_VIEW        @"_view"
#define KEY_ICON        @"_icon"
#define KEY_IDENTIFIER  @"_identifier"
#define KEY_STYLE       @"_style"

@class PATree;
@protocol PATreeDelegate <NSObject>
@optional
- (BOOL)tree:(PATree *)tree matchesSearch:(NSString *)searchString;
- (NSString *)tree:(PATree *)tree titleForSection:(NSInteger)section;
- (UITableViewCell *)tree:(PATree *)tree createCellForIdentifier:(NSString *)cellIdentifier;
- (void)tree:(PATree *)tree configureCell:(UITableViewCell *)cell;
@end

@interface PATree : NSObject <UITableViewDataSource, UISearchDisplayDelegate> {
    NSMutableDictionary *attributes;
    NSMutableArray *children;
    NSMutableArray *sections;
    NSMutableArray *searchResults;
    id <PATreeDelegate> delegate;
    
    // Temporary storage for importer
    NSString *titleKey;
    NSString *indexKey;
}

@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, assign) id <PATreeDelegate> delegate;
@property (nonatomic, retain) NSString *indexKey;

+ (id)treeWithDictionary:(NSDictionary *)dict;

- (id)initWithDictionary:(NSDictionary *)dict;
- (PATree *)addNode:(NSDictionary *)node;
- (void)addTree:(PATree *)tree;
- (void)addTitles:(NSString *) firstTitle, ...;
- (void)groupBy:(NSString *)groupKey;
- (void)extractSectionsBy:(NSString *)sectionKey;
- (void)removeLocalizedDuplicates;
- (void)setSearchString:(NSString *)search;
- (void)sortByKey:(NSString *)attr;
- (void)sortByKeys:(NSArray *)attrs;
- (BOOL)loadCSV:(NSString *)path error:(NSError **)error title:(NSString *)titleKey;
- (BOOL)loadCSV:(NSString *)path error:(NSError **)error target:(id)target selector:(SEL)selector;
- (PATree *)nodeAtIndexPath:(NSIndexPath *)indexPath;
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;

@end
