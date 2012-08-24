//
//  CustomMessageCell.h
//  Chatty
//
//  Created by Gabriel Hernandez on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//this is the cell we will be using for all conversations
@interface CustomMessageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *SenderUser;
@property (strong, nonatomic) IBOutlet UILabel *MessageUser;
@property (strong, nonatomic) IBOutlet UILabel *Recipients;
@property (strong, nonatomic) IBOutlet UIImageView *ProfilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;

@end
