//
//  CustomMessageCell.m
//  Chatty
//
//  Created by Gabriel Hernandez on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomMessageCell.h"

@implementation CustomMessageCell
@synthesize SenderUser;
@synthesize MessageUser;
@synthesize Recipients;
@synthesize ProfilePicture;
@synthesize userName;
@synthesize cumulativeLikes;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)likeAction
{
    NSLog(@"Like action depressed");
}

@end
