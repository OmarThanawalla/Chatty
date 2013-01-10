//
//  ConversationMe.h
//  Chatty
//
//  Created by Omar Thanawalla on 10/25/12.
//
//

#import <UIKit/UIKit.h>

@interface ConversationMe : UITableViewController

@property (assign, nonatomic) int currentView;
@property (strong, nonatomic) NSString *conversationID;
@property (strong, nonatomic) NSArray * messages;
@property (strong, nonatomic) NSArray * convoMessages;
@property (strong, nonatomic) NSString *preAddressing;

-(void) refresh;

@end
