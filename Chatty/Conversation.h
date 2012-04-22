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

@property (nonatomic, strong) NSMutableArray *people;
@property (nonatomic, strong) NSMutableArray *conversation;
@property (assign, nonatomic) int state;

@end
