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
@property (nonatomic, strong) NSMutableArray *follows;
@property (nonatomic, strong) NSMutableArray *follows2;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *Bio;
@property (nonatomic, strong) NSString *userName;

- (IBAction)toggleView:(id)sender;
-(IBAction) logout;
-(IBAction) refresh;



@end
