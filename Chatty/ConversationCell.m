//
//  ConversationCell.m
//  Chatty
//
//  Created by Gabriel Hernandez on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationCell.h"

@implementation ConversationCell

@synthesize names, conversation, cellHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.names = @"Gabe, Omar, Payton";
        self.conversation = @"Payton: Yo Gabe and Omar, thanks for helping with my game hey htere waht are you doing i am ok i just ate taco bell.";
        self.textLabel.text = names;
        self.detailTextLabel.text = conversation;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.detailTextLabel.numberOfLines = 0;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





@end
