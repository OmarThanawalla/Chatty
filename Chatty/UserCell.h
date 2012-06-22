//
//  UserCell.h
//  Chatty
//
//  Created by Omar Thanawalla on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *profilePic;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UILabel *bio;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, assign) int requestSent;
@property (nonatomic, strong) IBOutlet UIButton *requestButton;


-(IBAction)follow;
-(void) hasFriendship;

@end
