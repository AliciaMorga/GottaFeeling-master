//
//  TabView.h
//  tabs
//
//  Created by Liam Hennessy on 19/11/2010.
//  Copyright 2010 GloboForce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BUTTON_X_PADDING  5
#define BUTTON_Y_PADDING  5
#define IMAGE_WIDTH       10
#define IMAGE_HEIGHT      9
#define MENU_FONT         @"TimesNewRomanPS-BoldMT"
#define MENU_FONT_SIZE    13

@protocol TabViewDelegate;

@interface TabView : UIView {
    NSArray *_tabTitles;
    NSInteger _selectedItem;
    NSInteger _baseMenuType;
    id <TabViewDelegate> _delegate;
}

@property (nonatomic, retain) NSArray *tabTitles;
@property (nonatomic) NSInteger selectedItem;
@property (nonatomic) NSInteger baseMenuType;
@property (nonatomic, assign) IBOutlet id <TabViewDelegate> delegate;

-(void) menuItemClicked:(id)sender;
-(void) clearSubViews;

@end

@protocol TabViewDelegate <NSObject>
@optional
- (void)menuItemChanged:(NSInteger)previousItem newItem:(NSInteger)newItem;
@end
