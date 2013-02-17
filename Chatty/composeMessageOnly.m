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
    [messageBody becomeFirstResponder];
    NSLog(@"The value of conversation ID for composeMessageOnly class is %@", conversationID);
    [messageBody setText:preAddressing];
    messageBody.delegate = self;
    int count = 140 - [messageBody.text length];
    [characterCount setTitle:[NSString stringWithFormat:@"%d", count]];
    autoCompleteObject = [[autoCompleteEngine alloc] init]; //ready this object to be viewed on and off
    viewOn = NO;
    messageBody.scrollEnabled = YES; //Im not sure if this worked
    
    self.theWord = [[NSMutableString alloc] init];
    [self.theWord setString:@""];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyAction:) name:@"userNameSelected" object:nil];
    
    //set up the color
    self.navBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];
    self.statusBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];

    [TestFlight passCheckpoint:@"composeMessageOnly view was loaded"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    viewOn = NO;
    [theWord setString:@""];
    [[NSNotificationCenter defaultCenter] removeObserver:self];  //this is to avoid notification being sent here when we are in composeMessageOnly due to the face that we are using autoCompleteEngine class there too.
}

- (void)viewDidUnload
{
    [self setNavBar:nil];
    [self setStatusBar:nil];
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
    [TestFlight passCheckpoint:@"ComposeMessageOnly cancel button was hit"];
    [self.presentingViewController dismissModalViewControllerAnimated:YES];   
   
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView //calls this method because "becomeFirstResponder"
{
    //Simulate placeholder text
    messageBody.text = self.preAddressing;
    //messageBody.textColor = [UIColor lightGrayColor];
    //messageBody.selectedRange = NSMakeRange(0, 0);
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    [TestFlight passCheckpoint:@"ComposeMessageOnly: User begin editing text in"];
    //Clear placeholder
    if(messageBody.textColor == [UIColor lightGrayColor])
    {
        messageBody.textColor= [UIColor blackColor];
        NSRange clearMe = NSMakeRange(1, messageBody.text.length -1);     //grab the front rest of the string
        messageBody.text = [messageBody.text stringByReplacingCharactersInRange: clearMe withString:@""]; //clear that front rest
    }
    
    //counter
    int count = 140 - [messageBody.text length];
    [characterCount setTitle:[NSString stringWithFormat:@"%d", count]];
    
    int cursorPostion = [messageBody selectedRange].location;
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
        CGRect temp2 = messageBody.frame;
        temp2.size.height = 158;
        messageBody.frame = temp2;
        
        //clear theWord
        [theWord setString:@""];
        return;
    }
    //Begin Checking if we should be Turning on Autocomplete
    NSLog(@"cursorPostion %i",cursorPosition);
    while(cursorPosition != 0)
    {
        //NSLog(@"the letter at cursor space is %c", [myTextView.text characterAtIndex:cursorPosition-1]);
        char currentLetter = [messageBody.text characterAtIndex:cursorPosition-1];
        if(currentLetter == ' '|| currentLetter == '\n')
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
                CGRect temp2 = messageBody.frame;
                temp2.size.height = 158;
                messageBody.frame = temp2;
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
                temp.size.height = 120;
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
    int cursorPosition = [messageBody selectedRange].location;
    //NSLog(@"The contents in the textbox are: %@", myTextView.text);
    //NSLog(@"Cursor position is %i",cursorPosition);
    while(cursorPosition != 0)
    {
        char currentLetter = [messageBody.text characterAtIndex:cursorPosition-1];
        if(currentLetter == '@')
        {
            //Append userName to the right of @sign
            NSMutableString *messageContent = [NSMutableString stringWithString:messageBody.text];
            [messageContent appendString:userName];             //append the userName to the end
            [messageContent appendString:@" "];                 //append a space at the end
            [NSString stringWithString:messageContent];         //convert mutableString back to string
            messageBody.text = messageContent;
            
            int cursorPostion = [messageBody selectedRange].location;
            [self callAutoComplete:cursorPostion];
            return;
        }
        //delete the letter to the left (kinda verbose I know, but it works!)
        messageBody.text = [messageBody.text substringToIndex:[messageBody.text length] -1];
        cursorPosition--;
    }
}


-(IBAction)submit
{
    [TestFlight passCheckpoint:@"composeMessageOnly: User hit the submit button"];
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
                                     //Hit the refreshTheDatabase method in conversation.m file    
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"composeMessageOnly" object:nil userInfo:nil];    
                                      } 
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                      }];

    [self.presentingViewController dismissModalViewControllerAnimated:YES]; 
}
@end
