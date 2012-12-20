//
//  autoCompleteEngine.h
//  Chatty
//
//  Created by Omar Thanawalla on 12/16/12.
//
//

#import <UIKit/UIKit.h>

@interface autoCompleteEngine : UITableViewController


@property (nonatomic, strong) NSMutableArray *myUsers;
@property (nonatomic, strong) NSString *currentQuery; //holds the current query

-(void) searchKickOff: (NSString *) query;
-(void) refresh;
@end
