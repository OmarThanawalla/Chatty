//
//  top150.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Me : UITableViewController

@property (nonatomic, strong) NSMutableArray *conversations;
@property (nonatomic, strong) NSMutableArray * convoMessages;


//This is for CoreData
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, assign) BOOL lock;    //this is to lock the refresh method until data comes back from the server





-(IBAction)refresh;
-(IBAction)callToRefresh;

@end
