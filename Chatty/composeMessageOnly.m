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
#import "autoCompleteEngine.h"

@implementation composeMessageOnly
@synthesize  messageBody, conversationID, preAddressing, characterCount;
@synthesize autoCompleteObject;
@synthesize viewOn;

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
    [messageBody setText:preAddressing];
    messageBody.delegate = self;
    int count = 140 - [messageBody.text length];
    [characterCount setTitle:[NSString stringWithFormat:@"%d", count]];
    autoCompleteObject = [[autoCompleteEngine alloc] init]; //ready this object to be viewed on and off
    viewOn = NO;
    messageBody.scrollEnabled = YES; //Im not sure if this worked
}

-(void)viewDidDisappear:(BOOL)animated
{
    viewOn = NO;
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

-(void)textViewDidChange:(UITextView *)textView
{
    int count = 140 - [messageBody.text length];
    [characterCount setTitle:[NSString stringWithFormat:@"%d", count]];
    
    int cursorPostion = [messageBody selectedRange].location;
    [self callAutoComplete:cursorPostion];
    
}

-(void) callAutoComplete:(int) cursorPosition   //handles the autoCompletion of @sign
{
    //dont do anything because theres no letter to the left
    if(cursorPosition == 0) 
    {
        //Corner Case: If user hits @ sign then backspaces leaving the cursor at position 0
        for (UIView *subView in self.view.subviews)
        {
            if (subView.tag == 1)               //autoCompleteObject tag is 1
            {
                [subView removeFromSuperview];
            }
        }
        //Flip the viewOn "switch" to off
        viewOn = NO;
        
        //Return UITextView back to normal dimensions
        CGRect temp2 = messageBody.frame;
        temp2.size.height = 158;
        messageBody.frame = temp2;
        
        return;
    }
    //Begin Checking if we should be Turning on Autocomplete
    NSLog(@"cursorPostion %i",cursorPosition);
    while(cursorPosition != 0)
    {
        //NSLog(@"the letter at cursor space is %c", [myTextView.text characterAtIndex:cursorPosition-1]);
        char currentLetter = [messageBody.text characterAtIndex:cursorPosition-1];
        if(currentLetter == ' ')
        {
            NSLog(@"We have a space to the left of the word.");
            if (viewOn == YES)
            {
                //remove the subview from screen
                for (UIView *subView in self.view.subviews)
                {
                    if (subView.tag == 1)               //autoCompleteObject tag is 1
                    {
                        [subView removeFromSuperview];
                    }
                }
                //Flip the viewOn "switch" to off
                viewOn = NO;
                
                //Return UITextView back to normal dimensions
                CGRect temp2 = messageBody.frame;
                temp2.size.height = 158;
                messageBody.frame = temp2;
            }
            return;
        }
        if(currentLetter == '@')
        {
            NSLog(@"we have an @  sign to the left of the word");
            
            //display autocompletion feature
            if(viewOn == NO)
            {
                //Display a table view on screen
                autoCompleteObject.view.tag = 1;
                //Change the viewControlers frame
                CGRect temp = autoCompleteObject.view.frame;
                temp.origin.y = 85;
                autoCompleteObject.view.frame = temp;
                
                [self.view addSubview:autoCompleteObject.view];
                //Flip viewOn "switch" to on
                viewOn = YES;
                
                //Shorten the UITextView Box
                CGRect temp2 = messageBody.frame;
                temp2.size.height = 40;
                messageBody.frame = temp2;
                //Scroll to the bottom of the UITextView Box because we assume curosor is as bottom of textview
                NSRange myRange = NSMakeRange(messageBody.text.length-1 ,messageBody.text.length);
                [messageBody scrollRangeToVisible:myRange];
            }
            //constantly update the viewcontroller with the new text
            
            return;
        }
        cursorPosition--;
    }
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
