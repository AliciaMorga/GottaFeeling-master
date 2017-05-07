//
//  SettingsButtonCell.m
//  GottaFeeling
//
//  Created by Sheldon Conaty on 25/07/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import "SettingsButtonCell.h"

@implementation SettingsButtonCell

@synthesize stringsTable, configuration, changedsettings;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    if (self) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = UITextAlignmentLeft;
        
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.backgroundColor = [UIColor clearColor];     // iOS 5 uses off white color for cell background so label can't be white
        titleLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:titleLabel];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return self;
}

- (void)dealloc {
    [titleLabel release];
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect titleFrame = titleLabel.frame;
    titleFrame.origin.x = 10;
    
    titleFrame.size.width = self.contentView.frame.size.width - 20;
    titleFrame.size.height = self.contentView.frame.size.height;
    
    titleLabel.frame = titleFrame;
}

- (void) setConfiguration:(NSDictionary *)config {
    configuration = config;
    titleLabel.text = NSLocalizedStringFromTable([configuration objectForKey:@"Title"], stringsTable, nil);
}


#pragma mark - Properties

- (void)setValue:(NSObject *)newvalue {
    [value release];
    value = [newvalue retain];
    titleLabel.text = (NSString *)value;
}

- (NSObject *)value {
    return value;
}

@end
