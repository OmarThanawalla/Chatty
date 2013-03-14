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


@property (assign, nonatomic) int currentView; //this was for when i had segmented view, which is not part of version 1.0 anymore
@property (nonatomic, strong) NSMutableArray * innerCircleConversations;
@property (nonatomic, strong) NSMutableArray * allConversations;
@property (nonatomic, strong) NSMutableArray * variableCellHeight;
@property (nonatomic, strong) NSMutableArray * convoMessages;
@property (nonatomic, strong) NSMutableArray * listOfImages;
@property (nonatomic, assign) BOOL lock;    //this is to lock the refresh method until data comes back from the server
@property (nonatomic, strong) NSMutableArray *preloadedPictures;
//This is for CoreData
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;


- (IBAction)toggleView:(UISegmentedControl *)sender;
-(IBAction)refresh;

@end
