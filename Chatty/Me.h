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





-(IBAction)refresh;


@end
