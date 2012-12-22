//
//  editProfileModal.h
//  Chatty
//
//  Created by Omar Thanawalla on 12/22/12.
//
//

#import <UIKit/UIKit.h>

@interface editProfileModal : UIViewController

//@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *save;

@property (nonatomic, strong) IBOutlet UITextField *firstName;
@property (nonatomic, strong) IBOutlet UITextField *lastName;
@property (nonatomic, strong) IBOutlet UITextField *Bio;
@property (nonatomic, strong) IBOutlet UIImageView *profilePic;

-(IBAction)cancel;
-(IBAction)save;
-(IBAction)editPicture;

@end
