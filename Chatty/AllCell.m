//
//  AllCell.m
//  Chatty
//
//  Created by Gabriel Hernandez on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllCell.h"

@implementation AllCell
@synthesize allName,allConvo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
     self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.allName = @"Brtiney, Kobe, Arnold";
        self.allConvo = @"Kobe: Omar and Gabe are so cool imma take them tot he lakers game";
        self.textLabel.text = self.allName;
        self.detailTextLabel.text = self.allConvo;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.detailTextLabel.numberOfLines = 0;
    }
    return self;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
