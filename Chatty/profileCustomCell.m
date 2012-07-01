//
//  profileCustomCell.m
//  Chatty
//
//  Created by Gabriel Hernandez on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "profileCustomCell.h"
#import "editProfile.h"

@implementation profileCustomCell
@synthesize BioText;
@synthesize NameText;
@synthesize ProfilePic;
@synthesize userName;

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
-(IBAction)editProfile
{
    NSLog(@"You pushed the edit profile button");
        
}

@end
