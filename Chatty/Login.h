//
//  Login.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Login : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *emailBox;
@property (nonatomic, retain) IBOutlet UITextField *passwordBox;


-(IBAction) login;


@end
