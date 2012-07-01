//
//  MeTab.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Profile : UITableViewController

@property (nonatomic, assign) int currentView;
@property (nonatomic, strong) NSMutableArray * name;
@property (nonatomic, strong) NSMutableArray * tag;



- (IBAction)toggleView:(id)sender;
-(IBAction) logout;



@end
