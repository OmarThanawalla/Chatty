//
//  editProfileModal.h
//  Chatty
//
//  Created by Omar Thanawalla on 12/22/12.
//
//

#import <UIKit/UIKit.h>

@interface editProfileModal : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancel;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *save;

@property (nonatomic, strong) IBOutlet UITextField *firstName;
@property (nonatomic, strong) IBOutlet UITextField *lastName;
@property (nonatomic, strong) IBOutlet UITextView *Bio;
@property (nonatomic, strong) IBOutlet UIImageView *profilePic;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSMutableDictionary *resultsDict;
@property (nonatomic, strong) IBOutlet UINavigationBar *myNavBar;


-(IBAction)cancel;
-(IBAction)save;
-(IBAction)editPicture;

@end
