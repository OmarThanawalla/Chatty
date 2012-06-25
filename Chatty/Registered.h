//
//  Registered.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Registered : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *email;
@property (nonatomic, strong) IBOutlet UITextField *confirmEmail;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UITextField *confirmPassword;

-(IBAction) continue;

@end
