//
//  TagsTab.h
//  Chatty
//
//  Created by Gabriel Hernandez on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Search.h"
#import "Followers.h"
#import "UserFollowCell.h"


@interface TagsTab : UITableViewController

@property (strong, nonatomic) Search *mySearch;
@property (strong, nonatomic) Followers *myFollowers;
@property (nonatomic, assign) int currentView;

- (IBAction)changeView:(id)sender;

@end
