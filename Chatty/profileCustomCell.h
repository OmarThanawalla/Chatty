//
//  profileCustomCell.h
//  Chatty
//
//  Created by Gabriel Hernandez on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface profileCustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *BioText;
@property (strong, nonatomic) IBOutlet UILabel *NameText;
@property (strong, nonatomic) IBOutlet UIImageView *ProfilePic;
@property (strong, nonatomic) IBOutlet UILabel *userName;

-(IBAction) editProfile;
-(IBAction) launchFeedBack;

@end
