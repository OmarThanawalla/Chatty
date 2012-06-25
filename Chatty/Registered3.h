//
//  Registered3.h
//  Chatty
//
//  Created by Omar Thanawalla on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Registered3 : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *firstName;
@property (nonatomic, strong) IBOutlet UITextField *lastName;
@property (nonatomic, strong) IBOutlet UITextField *userName;
@property (nonatomic, strong) IBOutlet UITextField *bio;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString *password;




-(IBAction)register;

@end
