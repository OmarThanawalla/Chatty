//
//  conversationTop60.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"
@interface Conversation : UITableViewController

@property (assign, nonatomic) int currentView;
@property (strong, nonatomic) NSString *conversationID;
@property (strong, nonatomic) NSArray * messages;
@property (strong, nonatomic) NSString *preAddressing;

-(void) refresh;

@end


