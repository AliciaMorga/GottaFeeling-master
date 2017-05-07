//
//  TabView.m
//  tabs
//
//  Created by Liam Hennessy on 19/11/2010.
//  Copyright 2010 GloboForce Ltd. All rights reserved.
//

#import "TabView.h"


@implementation TabView
@synthesize tabTitles=_tabTitles;
@synthesize delegate=_delegate;
@synthesize selectedItem=_selectedItem;
@synthesize baseMenuType=_baseMenuType;

- (void)clearSubViews {
  for (UIView *v in self.subviews) {
    [v removeFromSuperview];
  }
}
  
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)layoutTabs {
    UIFont *buttonFont = [UIFont fontWithName:MENU_FONT size:MENU_FONT_SIZE];
    CGFloat buttonsWidth = 0;
    for (NSString *title in self.tabTitles) {
        buttonsWidth += IMAGE_WIDTH+[title sizeWithFont:buttonFont].width;
    }
    buttonsWidth += 2*BUTTON_X_PADDING;
    // Calculate the spacing between menu items
    // e.g. For 3 items the first should be flush left, third flush right and the 
    // second in the middle of both (with the same padding on both sides)
    // 
    CGRect rect = self.bounds;
    CGFloat menuSpacing = roundf((rect.size.width - buttonsWidth-2*BUTTON_Y_PADDING)/([self.tabTitles count]-1));

    CGFloat startPoint = BUTTON_Y_PADDING; // variable to store where the next button will start
    [self clearSubViews];

    for (int i=0; i<[self.tabTitles count]; i++) {
    
        CGSize textSize = [[self.tabTitles objectAtIndex:i] sizeWithFont:buttonFont];
        CGFloat buttonWidth = IMAGE_WIDTH+textSize.width;
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(startPoint, 0, buttonWidth, rect.size.height)];
        startPoint += buttonWidth+menuSpacing;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, roundf((rect.size.height-IMAGE_HEIGHT)/2), IMAGE_WIDTH, IMAGE_HEIGHT)];
        imageView.image = [UIImage imageNamed:@"ArrowBlack.png"];

        UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        button.frame = CGRectMake(IMAGE_WIDTH, 0, textSize.width+2*BUTTON_X_PADDING, rect.size.height);
        // Set the tag on the button to be the base menu
        // The index into the array will provide the caller with the ability to
        // select the appropriate picker type
        
        button.tag = self.baseMenuType+i;
        if (i==0) { // When we're drawing, select the first item
            button.selected = YES;
            self.selectedItem = button.tag;
        }
        
        button.titleLabel.font = buttonFont;
        button.titleLabel.textColor = [UIColor blackColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateReserved];

        NSString *buttonTitle = NSLocalizedString([self.tabTitles objectAtIndex:i], nil);
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button setTitle:buttonTitle forState:UIControlStateHighlighted];
        [button setTitle:buttonTitle forState:UIControlStateSelected];
        [button setTitle:buttonTitle forState:UIControlStateDisabled];
        [button setTitle:buttonTitle forState:UIControlStateReserved];

        [button addTarget:self action:@selector(menuItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:imageView];
        [buttonView addSubview:button];


        [imageView release];
        [button release];

        [self addSubview:buttonView];
    }
}

-(void) menuItemClicked:(id)sender {
    UIButton *menuItem = (UIButton*)sender; 
    menuItem.selected=YES;

    if (self.selectedItem!=menuItem.tag) {
        UIButton *oldMenuItem = (UIButton*)[self viewWithTag:self.selectedItem];
        if ([oldMenuItem isKindOfClass:[UIButton class]]) {
            oldMenuItem.selected = NO;
        }
        if (self.delegate) {
            [self.delegate menuItemChanged:self.selectedItem newItem:menuItem.tag];
        }
        self.selectedItem = menuItem.tag;
    } 
}
     
- (void)setTabTitles:(NSArray *)tabTitles {
    [_tabTitles release];
    _tabTitles = [tabTitles retain];
    
    [self layoutTabs];
}

- (void)dealloc {
	[_tabTitles release], _tabTitles = nil;
    [super dealloc];
}


@end