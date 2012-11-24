//
//  top60.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Community.h"
#import "Conversation.h"
#import "Login.h"
#import "AllCell.h"
#import "CustomMessageCell.h"

//import AFNetworking
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
#import "KeychainItemWrapper.h"


@implementation Community


@synthesize currentView;
@synthesize innerCircleConversations, allConversations;
@synthesize variableCellHeight;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        //you start off in state inner circle
         // ive hidden the segmented control so we should always be in currentView 1
        
        // current view 1 is all view which is what i want in the beginning
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    //setting currentView to 1 here because I removed the toggling of AllConvo's and FavoriteConvo's
    self.currentView = 1;
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    NSLog(@"%@, %@", email, password);
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            nil];
    NSLog(@"the current view on viewDidLoad %d", currentView);
    if(currentView == 0)
    {
    [[AFChattyAPIClient sharedClient] getPath:@"/inner_conversation/" parameters:params 
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          NSLog(@"Response: %@", responseObject);
                                          //rmr: responseObject is an array where each element is a diciontary
                                          innerCircleConversations = responseObject;
                                          [self.tableView reloadData];
                                          
                                          
                                      } 
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                          [self performSegueWithIdentifier:@"loggedIn" sender:self];
                                      }];
    }
    else //you are in All Conversations view
    {

        
        [[AFChattyAPIClient sharedClient] getPath:@"/conversation/" parameters:params 
         //if login works, log a message to the console
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                              NSLog(@"Response: %@", responseObject);
                                              //rmr: responseObject is an array where each element is a diciontary
                                              allConversations = responseObject;
                                              [self.tableView reloadData];
                                              
                                              
                                          } 
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                              //else you cant connect, therefore push modalview login onto the stack
                                              [self performSegueWithIdentifier:@"loggedIn" sender:self];
                                          }];
        
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(currentView == 0)
    {
    return [innerCircleConversations count]; //self.results.count;
    }
    else
    {
        return [allConversations count];
    }
}


//is called on refresh, view did load, and toggling of state
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //as long as you register the nib, dequeueReusableCellWithIdentifier will use the 'nib registry' to load a new cell from a nib file
    //the reason why is table view is so smart it keeps track of which reuse identifiers are meant to be associated with particular nib files
    
    static NSString *CellIdentifier = @"CustomCellIdentifier";
   
    //DONT LOOK AT THIS IF STATEMENT BECAUSE YOU DON'T HAVE AN INNER CIRCLE CONVERSATION TAB 
    if(currentView == 0){ //current view is Inner Circle
        /*
        static BOOL nibsRegistered = NO;
        if(!nibsRegistered)
        {
            UINib *nib = [UINib nibWithNibName: @"CustomMessageCell" bundle:nil]; //grab nib
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];//register nib
            //nibsRegistered = YES;
        }
        
        CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      
        //customize cell
        
        NSDictionary *tweet = [innerCircleConversations objectAtIndex:indexPath.row];
        cell.MessageUser.text = [tweet objectForKey:@"message_content"];
        cell.MessageUser.lineBreakMode = UILineBreakModeWordWrap;
        cell.MessageUser.numberOfLines = 0;
        
        
        cell.SenderUser.text = [tweet objectForKey:@"full_name"];
        cell.Recipients.text = [tweet objectForKey:@"recipient"]; //Message content will reveal recipients
        
        
        return cell;
         */
    }
      
    
    //THIS IS DOING ALL YOUR WORK. YAY. I LOVE WORK.
    else { //current view is ALL
        static BOOL nibsRegistered = NO;
        if(!nibsRegistered)
        {
            UINib *nib = [UINib nibWithNibName: @"CustomMessageCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            //nibsRegistered = YES;
        }
        
        CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //        cell.SenderUser.text = @"Dr. Mitra";
        //        cell.Recipients.text = @"Gabe, Omar, Dr. Mitra";
        //NSDictionary *tweet = [self.results objectAtIndex:indexPath.row];
        //cell.SenderUser.text = [tweet objectForKey:@"from_user"];
        //cell.MessageUser.text = [tweet objectForKey:@"text"];
        
        NSDictionary *tweet = [self.allConversations objectAtIndex:indexPath.row];
        cell.MessageUser.text = [tweet objectForKey:@"message_content"];
        cell.MessageUser.lineBreakMode = UILineBreakModeWordWrap;
        cell.MessageUser.numberOfLines = 0; //You'll notice that I set the number of lines for the label to 0. This lets it use as many lines as it needs.
        
        
        
        
        //SIZE AND WIDTH OF MESSAGE CONTENT LABEL
        //trying to alter the UILabel Size
        NSString *cellText = cell.MessageUser.text;             //grab the message 
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
        CGSize constraintSize = CGSizeMake(220.0f, MAXFLOAT);   //This sets how wide we can go
        CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];

        //you are able to assign the frame but not the fields of the frame
        //effectively what it does is: sets the frame size for UILabel
        //Now what frames are and how this all works with UILabel, I dont know. lol
        CGRect temp = cell.MessageUser.frame;
        temp.size = labelSize;
        cell.MessageUser.frame = temp;
        [cell.MessageUser sizeToFit];
        NSLog(@"fasldjf;alsdkfj;alsdkjfadks %lf", cell.MessageUser.frame.size.height);
        
        
        
        cell.SenderUser.text = [tweet objectForKey:@"full_name"];
        
        //MODIFY RECIPIENTS UILABEL
        cell.Recipients.text = [tweet objectForKey:@"recipient"];
        //grab recipients frame so i can modify it's height
        CGRect temp2 = cell.Recipients.frame;
        temp2.origin.x = 77;
        //
        int messageHeight = cell.MessageUser.frame.size.height;
        temp2.origin.y = 30 + messageHeight; //this is what i have to calculate        
        cell.Recipients.frame = temp2;
        
        //userName label
        cell.userName.text = [tweet objectForKey:@"userName"];
        
        
        
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // #1 Get the labelSize
    //grab the tweet
    NSDictionary *tweet = [self.allConversations objectAtIndex:indexPath.row];
    //grab the text out of the tweet
    NSString *cellText = [tweet objectForKey:@"message_content"];             //grab the message 
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    CGSize constraintSize = CGSizeMake(220.0f, MAXFLOAT);                     //This sets how wide we can go
    //calculate labelSize
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    // #2 Create the label
    CGRect labelFrame = CGRectMake(0, 0, labelSize.width, labelSize.height);//created a label frame
    UILabel *myLabel = [[UILabel alloc] initWithFrame: labelFrame];         //created a label
    
    
    
    
    
    //BEGIN WEIRD HACK:
    [myLabel setText:cellText];
     myLabel.lineBreakMode = UILineBreakModeWordWrap;
    [myLabel setNumberOfLines:0];
    NSString *cellText2 = [tweet objectForKey:@"message_content"];
    UIFont *cellFont2 = [UIFont fontWithName:@"Helvetica" size:17.0];
    CGSize constraintSize2 = CGSizeMake(220.0f, MAXFLOAT);
    CGSize labelSize2 = [cellText2 sizeWithFont:cellFont2 constrainedToSize:constraintSize2 lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect temp2 = myLabel.frame;
    temp2.size = labelSize2;
    myLabel.frame = temp2;    
    // #3 Call sizeToFit method
    [myLabel sizeToFit];                                                    //myLabel sizeToFit
    
    
    //NSLog(@"this is what labelSize was before: %lf",labelSize.height);
    NSLog(@"this is what labelSize is after sizeTofit: %lf",myLabel.frame.size.height);
    
//    NSString *cellText = @"fjsldfja;sldfja;sldkfja;sldkfja;slkdfj;aslkdfj;alskdjf;alskdfj;alskjdf;aslkdfj;aslkjdf;laskdf;alskjf;laskjdf;alskjfd;alskjf;alskdjf;alskdfj;alskdjf;alskdjf;alskdjf;aslkdjfa;skdjflaskjdf;laskjdf;laksjfd;lkasjdf;laskjdf;laskjdf;alskdjf;laskdjf;alskdjf;alskjdfa;lskdjfa;lksdfj;alksdkjfals;dkfja;lskdjfl;alskdjf";
//    
//    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
//    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
//    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
//    
//    return labelSize.height + 20;
    
    return 60 + myLabel.frame.size.height;
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





#pragma mark - Table view delegate
//drill down into the conversation
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentView == 0) 
    {
    
        NSDictionary *tweet = [innerCircleConversations objectAtIndex:indexPath.row];
        NSString *convoID = [tweet objectForKey:@"conversation_id"];
        [self performSegueWithIdentifier:@"ShowMyCommunityMessages" sender:convoID];
    }      
          
    if(currentView == 1)
    {
        NSDictionary *tweet = [allConversations objectAtIndex:indexPath.row];
        NSString *convoID = [tweet objectForKey:@"conversation_id"];
        [self performSegueWithIdentifier:@"ShowMyCommunityMessages" sender:convoID];
    }
          
    
}

//drill down into the conversation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    
    if ([segue.identifier isEqualToString:@"ShowMyCommunityMessages"]) 
    {
        Conversation *messageView = [segue destinationViewController];
        
        if(currentView == 0)
        {
            messageView.currentView = 0;
            NSString *convoID = sender;
            messageView.conversationID = convoID;
        }
        if(currentView == 1)
        {
            messageView.currentView = 1;
            NSString * convoID = sender;
            messageView.conversationID = convoID;
        }
    }
}





///////////////////////////////////////////////////////////////////////////////////////////////


//update the state of the object, are you in inner circle or all

- (IBAction) toggleView:  (UISegmentedControl *)sender {
    if([sender selectedSegmentIndex] == 1)
    {
        //change state
        self.currentView = 1;
        //when segments, call the refresh method. especially important on first switch to all
        [self refresh];
        //reload table data, this will reload the correct array depending on the state of things
        [self.tableView reloadData]; 
        
        NSLog(@"current view set to 1");
    } else {
        self.currentView = 0;
        [self.tableView reloadData]; 
        NSLog(@"current view set to 0");
    }

}

///////////////////////////////////////////////////////////////////////////////////////////////



-(IBAction) refresh
{
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];

    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            nil];
    if(currentView == 0)
    {
        [[AFChattyAPIClient sharedClient] getPath:@"/inner_conversation/" parameters:params 
         //if login works, log a message to the console
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                              NSLog(@"Response: %@", responseObject);
                                              //rmr: responseObject is an array where each element is a diciontary
                                              innerCircleConversations = responseObject;
                                              [self.tableView reloadData];
                                          } 
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                              //else you cant connect, therefore push modalview login onto the stack
                                              [self performSegueWithIdentifier:@"loggedIn" sender:self];
                                          }];
    }
    else //you are in All Conversations view
    {
        [[AFChattyAPIClient sharedClient] getPath:@"/conversation/" parameters:params 
         //if login works, log a message to the console
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                              NSLog(@"Response: %@", responseObject);
                                              //rmr: responseObject is an array where each element is a diciontary
                                              allConversations = responseObject;
                                              [self.tableView reloadData];
                                              
                                              
                                          } 
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                              //else you cant connect, therefore push modalview login onto the stack
                                              [self performSegueWithIdentifier:@"loggedIn" sender:self];
                                          }];
    }

    
    
}

    



@end
