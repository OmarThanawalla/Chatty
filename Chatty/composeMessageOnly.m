//
//  composeMessageOnly.m
//  Chatty
//
//  Created by Omar Thanawalla on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "composeMessageOnly.h"
#import "AFChattyAPIClient.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"

@implementation composeMessageOnly
@synthesize  messageBody, conversationID;



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
    [messageBody becomeFirstResponder];
    NSLog(@"The value of conversation ID for composeMessageOnly class is %@", conversationID);
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
-(IBAction)cancel
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];   
   
}

-(IBAction)submit
{
    //grab the contents of message body
    NSString *messageContent = self.messageBody.text;
    NSString *convoID = self.conversationID;
    
    //submit the message to the server
    
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
        
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            convoID, @"conversationID",
                            messageContent, @"message",
                            nil];
    [[AFChattyAPIClient sharedClient] postPath:@"/get_message/" parameters:params 
//     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSLog(@"This is the response I recieved in the message view: %@", responseObject);
                                      [self.presentingViewController dismissModalViewControllerAnimated:YES];                                                                                    
                                          
                                          
                                      } 
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                      }];

}
@end
