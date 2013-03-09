//
//  Registered3.h
//  Chatty
//
//  Created by Omar Thanawalla on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Registered3 : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITextField *firstName;
@property (nonatomic, strong) IBOutlet UITextField *lastName;
@property (nonatomic, strong) IBOutlet UITextField *userName;
@property (nonatomic, strong) IBOutlet UITextField *bio;
@property (nonatomic, strong) IBOutlet UILabel *notice;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImageView *profilePic;
@property (strong, nonatomic) IBOutlet UIImageView *displayedProfilePic;



-(IBAction)register;
-(void) submit;
- (IBAction)addPicture:(id)sender;

@end
