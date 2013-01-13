//
//  Login.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Login.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"
#import "AFChattyAPIClient.h"

@implementation Login
@synthesize emailBox, passwordBox;
@synthesize notice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Sign In";
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
     [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];
}


-(IBAction)login
{
    //when the login button is pushed
    
    
    // get these from the text box
    NSString *email = emailBox.text;
    NSString *password = passwordBox.text;
    NSLog(@"%@, %@", email, password);
    
    email = [email lowercaseString];
    
    //store the email and password in the KeyChain or NSUserDefaults. NOTE: I imported the KeychainItemWrapper and linked Secuirty.framework
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            nil];
    
    //try to login
    [[AFChattyAPIClient sharedClient] postPath:@"/login/attempt_login" parameters:params 
                //if successful dismiss the view
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSLog(@"Response: %@", responseObject);
                     //if successfully logged in, dismiss the modal view, looks like i store email and password
                     [keychain setObject:email forKey:(__bridge id) kSecAttrAccount];
                     [keychain setObject:password forKey:(__bridge id)kSecValueData];
                     [self dismissModalViewControllerAnimated:YES];

                 } 
                //else flash a notice on the modal view
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error from postPath: %@",[error localizedDescription]);
                     notice.text = @"Incorrect Password";
                 }];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
