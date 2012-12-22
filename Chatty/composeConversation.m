//
//  composeMessage.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "composeConversation.h"
#import "KeychainItemWrapper.h"
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
#import "autoCompleteEngine.h"

@implementation composeConversation
@synthesize myTextView, characterCount;
@synthesize autoCompleteObject;
@synthesize viewOn;
@synthesize theWord;

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
    //force the keyboard to open
    [self.myTextView becomeFirstResponder];
    self.myTextView.delegate = self;
    self.autoCompleteObject = [[autoCompleteEngine alloc] init]; //ready this object to be viewed on and off
    self.viewOn = NO;
    self.myTextView.scrollEnabled = YES; //Im not sure if this worked
    self.theWord = [[NSMutableString alloc] init];
    [self.theWord setString:@""];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyAction:) name:@"userNameSelected" object:nil];

}



-(void)viewDidDisappear:(BOOL)animated
{
    viewOn = NO;
    [theWord setString:@""];
    [[NSNotificationCenter defaultCenter] removeObserver:self];  //this is to avoid notification being sent here when we are in composeMessageOnly due to the face that we are using autoCompleteEngine class there too.
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

-(IBAction)cancelButton
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];   
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView //calls this method because "becomeFirstResponder"
{
    //Simulate placeholder text
    myTextView.text = @"Direct your message to someone using the @ sign";
    myTextView.textColor = [UIColor lightGrayColor];
    myTextView.selectedRange = NSMakeRange(0, 0);
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView //calls this method when you put text in it
{
    //Clear placeholder
    if(myTextView.textColor == [UIColor lightGrayColor])
       {
           myTextView.textColor= [UIColor blackColor];
           NSRange clearMe = NSMakeRange(1, myTextView.text.length -1);     //grab the front rest of the string
           myTextView.text = [myTextView.text stringByReplacingCharactersInRange: clearMe withString:@""]; //clear that front rest
       }
    //counter
    int count = 140 - [myTextView.text length];
    [characterCount setTitle:[NSString stringWithFormat:@"%d", count]];
    
    
    
    int cursorPostion = [myTextView selectedRange].location;
    [self callAutoComplete:cursorPostion];
    
}

-(void) callAutoComplete:(int) cursorPosition   //handles the autoCompletion of @sign
{
        [theWord setString:@""];    //clear theWord so we can update theWord to the "more user provided" information
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
            CGRect temp2 = myTextView.frame;
            temp2.size.height = 158;
            myTextView.frame = temp2;
            
            //clear theWord 
            [theWord setString:@""];
            
            return;
        }
        //Begin Checking if we should be Turning on Autocomplete
        //NSLog(@"cursorPostion %i",cursorPosition);
        
        while(cursorPosition != 0)
        {
                    //NSLog(@"the letter at cursor space is %c", [myTextView.text characterAtIndex:cursorPosition-1]);
                    char currentLetter = [myTextView.text characterAtIndex:cursorPosition-1];
                    if(currentLetter == ' ' || currentLetter == '\n')
                    {
                        NSLog(@"We have a space or new-line character to the left of the word.");
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
                            CGRect temp2 = myTextView.frame;
                            temp2.size.height = 158;
                            myTextView.frame = temp2;
                        }
                        //clear theWord 
                        [theWord setString:@""];
                        
                        return;
                    }
                    if(currentLetter == '@')
                    {
                        NSLog(@"we have an @  sign to the left of the word");
                        //Gotta add an @to theWord so we can send a good query to the server
                        NSString *temp3 = [NSString stringWithFormat:@"%c", currentLetter];
                        [theWord insertString:temp3 atIndex:0];
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
                            CGRect temp2 = myTextView.frame;
                            temp2.size.height = 40;
                            myTextView.frame = temp2;
                            //Scroll to the bottom of the UITextView Box because we assume curosor is as bottom of textview
                            NSRange myRange = NSMakeRange(myTextView.text.length-1 ,myTextView.text.length);
                            [myTextView scrollRangeToVisible:myRange];
                        }
                        
                        //constantly update the viewcontroller with the new text
                        [autoCompleteObject searchKickOff:theWord];     //send the word to the right of the @ sign
                       
                        return;
                    }
                    
                    //convert char into NSString
                    NSString *temp3 = [NSString stringWithFormat:@"%c", currentLetter];
                    //build up the chars into a string
                    [theWord insertString:temp3 atIndex:0];
                    //NSLog(@"The value of the word is %@",theWord);
                    cursorPosition--;
        }
}

//is called when autoCompleteEngine.m has a userName ready for us
-(void)anyAction:(NSNotification *)anote
{
    
    NSDictionary *dict = [anote userInfo];
    NSString *userName = [dict objectForKey:@"userName"];
    [self autoCompleteFinish:userName];
}

//inserts the userName into the textBox
-(void)autoCompleteFinish:(NSString *) userName
{
    //remove the @ in userName
    userName = [userName substringFromIndex:1];
    //NSLog(@"The value of userName in autoCompleteFinish is: %@",userName);
    int cursorPosition = [myTextView selectedRange].location;
    //NSLog(@"The contents in the textbox are: %@", myTextView.text);
    //NSLog(@"Cursor position is %i",cursorPosition);
    while(cursorPosition != 0)
    {
        char currentLetter = [myTextView.text characterAtIndex:cursorPosition-1];
        if(currentLetter == '@')
        {
            //Append userName to the right of @sign
            NSMutableString *messageContent = [NSMutableString stringWithString:myTextView.text];
            [messageContent appendString:userName];             //append the userName to the end
            [messageContent appendString:@" "];                 //append a space at the end
            [NSString stringWithString:messageContent];         //convert mutableString back to string
            myTextView.text = messageContent;
            
            int cursorPostion = [myTextView selectedRange].location;
            [self callAutoComplete:cursorPostion];
            return;
        }
        //delete the letter to the left (kinda verbose I know, but it works!)
        myTextView.text = [myTextView.text substringToIndex:[myTextView.text length] -1];
        cursorPosition--;
    }
}

-(IBAction)sendButton
{

    //grab the text from textView
    NSString * messageContent = myTextView.text;
    
    if([messageContent rangeOfString:@"@"].location == NSNotFound || (myTextView.textColor ==[UIColor lightGrayColor]) )
    {
        //alert the user that he must direct the conversation towards someone
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You must direct conversation towards someone with an @ sign to start a new convo."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else if ([myTextView.text length] > 140) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Message must be less than 140 characters"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    else
    {
        
        //submit the text to the server
        //were going to fake it and just add it to the array for the moment
        //grab credentials
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
        NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
        NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
        
        //try connecting with credentials
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                email, @"email",
                                password, @"password",
                                messageContent, @"message",
                                nil];
        
        // NSURL *url = [NSURL URLWithString:@"http://localhost:3000"];
        // AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        //
        //    [httpClient getPath:@"/my_conversation" parameters:nil
        //     //if login works, log a message to the console
        //                success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //                    NSLog(@"Response: %@", responseObject);
        //                    [self.presentingViewController dismissModalViewControllerAnimated:YES];
        //
        //                }
        //                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //                    NSLog(@"Error from postPath: %@",[error localizedDescription]);
        //                    self.dialogue.text = @"Error in sending. Try again later beautiful.";
        //                    //else you cant connect, therefore push modalview login onto the stack
        //                    //[self performSegueWithIdentifier:@"loggedIn" sender:self];
        //                }];
        //
        //
        [[AFChattyAPIClient sharedClient] postPath:@"/message" parameters:params
         //if login works, log a message to the console
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               NSLog(@"Response was good, here it is: %@", responseObject);
                                               [self.presentingViewController dismissModalViewControllerAnimated:YES];
                                               
                                           } 
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                               //else you cant connect, therefore push modalview login onto the stack
                                           }];
    }
}
@end
