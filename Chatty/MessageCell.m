//
//  MessageCell.m
//  Chatty
//
//  Created by Gabriel Hernandez on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell
@synthesize name,conversation, cellHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.name = @"Gabe";
        self.conversation = @"Gabe: Omar You are so sexy";
        self.textLabel.text = name;
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
