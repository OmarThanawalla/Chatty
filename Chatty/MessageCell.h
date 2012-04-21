//
//  MessageCell.h
//  Chatty
//
//  Created by Gabriel Hernandez on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *conversation;
@property (assign, nonatomic) NSUInteger cellHeight;



@end
