//
//  MeTab.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyProfile.h"
#import "MyConversation.h"

@interface MeTab : UITableViewController

@property (nonatomic, strong) MyConversation *convos;
@property (nonatomic, assign) int currentView;
@property (nonatomic, strong) MyProfile *profiles;

- (IBAction)toggleView:(id)sender;
- (IBAction)refreshTable:(id)sender;

@end
