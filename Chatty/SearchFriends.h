//
//  SearchFriends.h
//  Chatty
//
//  Created by Omar Thanawalla on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFriends : UIViewController<UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate >


@property (nonatomic, strong) NSString *searchQuery;
@property (nonatomic, strong) NSMutableArray *listOfUsers;

-(void) refresh;
- (IBAction)fbFriendSearch:(id)sender;

@end
