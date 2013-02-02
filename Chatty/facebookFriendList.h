//
//  facebookFriendList.h
//  Chatty
//
//  Created by Omar Thanawalla on 1/29/13.
//
//

#import <UIKit/UIKit.h>

@interface facebookFriendList : UITableViewController

@property (nonatomic, strong) NSMutableArray *listOfUsers;

- (IBAction)dismiss:(id)sender;
- (IBAction)followAll:(id)sender;


@end
