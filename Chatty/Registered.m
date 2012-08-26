    //
//  Registered.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Registered.h"
#import "Registered3.h"

@implementation Registered
@synthesize email, confirmEmail, password, confirmPassword;

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
    self.title = @"Registration: Step 1 of 2";
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


-(IBAction) continue
{

   BOOL goodToGo = NO;
    
   //if email and password box not empty 
    if(![email.text isEqualToString:@""] && ![password.text isEqualToString:@""])
    {
        //if email and password matches their confirmation boxes
        if([email.text isEqualToString:confirmEmail.text] && [password.text isEqualToString:confirmPassword.text])
        {
            //minimum password length
            if([password.text length] >= 8 )
            {
                goodToGo = YES;
            }
        }
    }
    
    if(goodToGo)
    {
        
        [self performSegueWithIdentifier:@"continueRegistered" sender:nil];
        NSLog(@"You hit the continue button and we were goodToGo ");
    }
    if(!goodToGo)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"Your email or password does not match. Check your spelling."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"continueRegistered"])
    {
        Registered3 * registered3 = [segue destinationViewController];
        registered3.email = self.email.text;
        registered3.password = self.password.text;
        
    }
}



@end
