//
//  top60.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//  
//  Community is the first tab
// conversation cell
//conversation top 60 is the class inside the community class
//conversation cell is inside community class
//message cell is inside the conversation top 60 class

#import <UIKit/UIKit.h>
#import "ConversationCell.h"

@interface Community : UITableViewController 

@property (nonatomic, strong) NSMutableArray *people;
@property (nonatomic,strong) NSMutableArray *conversations;
@property (assign, nonatomic) int currentView;
@property (nonatomic, strong) NSMutableArray * results;

- (IBAction)toggleView:(UISegmentedControl *)sender;

@end
