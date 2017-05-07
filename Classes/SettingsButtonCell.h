//
//  SettingsButtonCell.h
//  GottaFeeling
//
//  Created by Sheldon Conaty on 25/07/2011.
//  Copyright 2011 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsCellProtocol.h"


@interface SettingsButtonCell : UITableViewCell <SettingsCellProtocol> {
    UILabel *titleLabel;

    NSString *stringsTable;
    NSObject *value;
    NSDictionary *configuration;			
    NSMutableDictionary *changedsettings;	
}

@end
