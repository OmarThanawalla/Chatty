//
//  ResetPassword.h
//  Chatty
//
//  Created by Omar Thanawalla on 3/16/13.
//
//

#import <UIKit/UIKit.h>

@interface ResetPassword : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *currentPassword;
@property (nonatomic, strong) IBOutlet UITextField *updatePassword;
@property (nonatomic, strong) IBOutlet UITextField *updatePassword2;


-(IBAction)submit;
-(IBAction)dismiss;

@end
