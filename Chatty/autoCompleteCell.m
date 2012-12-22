//
//  autoCompleteCell.m
//  Chatty
//
//  Created by Omar Thanawalla on 12/16/12.
//
//

#import "autoCompleteCell.h"

@implementation autoCompleteCell
//I think i dont have to write @synthesize anymore


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

@end
