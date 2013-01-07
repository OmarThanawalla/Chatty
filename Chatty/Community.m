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
#import "Message.h"

#import "BIDAppDelegate.h" //This is for CoreData: in order to grab the managedObjectContext

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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:48.0/256.0 green:49.0/256.0 blue:50.0/256.0 alpha:1.0];
    
    //change tableview Image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:53.0/256.0 green:231.0/256.0 blue:132.0/256.0 alpha:1.0]];

    //setting currentView to 1 here because I removed the toggling of AllConvo's and FavoriteConvo's
    self.currentView = 1;
    
    
    //[self performSegueWithIdentifier:@"composeAConvo" sender:self];
    //[self.tabBarController setSelectedIndex:1];
    [self refresh];
   
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
   

        static BOOL nibsRegistered = NO;
        if(!nibsRegistered)
        {
            UINib *nib = [UINib nibWithNibName: @"CustomMessageCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            //nibsRegistered = YES;
        }
        
        CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
        //set cell to white color
        [cell setBackgroundColor:[UIColor whiteColor]];
    
        NSDictionary *tweet = [self.allConversations objectAtIndex:indexPath.row];
           
            //MessageUser Label
            CGRect labelFrame = CGRectMake(72.0f, 26.0f, 0.0f, 0.0f);   
            UILabel *myLabel = [[UILabel alloc] initWithFrame:labelFrame];  //initialize the label
            
            myLabel.text = [tweet objectForKey:@"message_content"];
            myLabel.font =[UIFont systemFontOfSize:13];
            myLabel.lineBreakMode = UILineBreakModeWordWrap;
            myLabel.numberOfLines = 0;                             //As many lines as it needs
            [myLabel setBackgroundColor:[UIColor whiteColor]];   //For debugging purposes
            myLabel.tag = 1;
            //Create Label Size
            NSString *cellText = [tweet objectForKey:@"message_content"];   //grab the message
            UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:13.0];
            CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);           //This sets how wide we can go
            CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];

           //Apend the labelSize and call sizeToFit
            CGRect temp = myLabel.frame;
            temp.size = labelSize;
            myLabel.frame = temp;                                  //so origin x,y should stil be in tact
            [myLabel sizeToFit];
            
            //Adding the label to the view
            if(cell.MessageUser == NULL){
                cell.MessageUser = myLabel;
                [cell.contentView addSubview:cell.MessageUser];
            }else{
                [cell.MessageUser removeFromSuperview];         //remove the old label before putting the new one in
                cell.MessageUser = myLabel;
                [cell.contentView addSubview:cell.MessageUser];
            }
        
        
        //SenderUser Label
        cell.SenderUser.text = [tweet objectForKey:@"full_name"];
        
        //Recipients Label
        cell.Recipients.text = [tweet objectForKey:@"recipient"];
        //grab recipients frame so i can modify it's height
        CGRect temp2 = cell.Recipients.frame;
        temp2.origin.x = 77;
        int messageHeight = myLabel.frame.size.height;
        temp2.origin.y = 35 + messageHeight; //this is what i have to calculate        
        cell.Recipients.frame = temp2;
        
        //userName label
        cell.userName.text = [tweet objectForKey:@"userName"];
    
        //set numberOfLikes on cell
        cell.cumulativeLikes.text = @"87";
    
    
        //load Profile Picture
    //dont forget to load from listOfImages Array
        NSString *picURL = [tweet objectForKey: @"profilePic"];
        NSLog(@"The url for the pic is: %@", picURL);
        [cell.ProfilePicture setImageWithURL:[NSURL URLWithString:picURL]];
       // UIImageView * profPic2 = [self.listOfImages objectAtIndex:indexPath.row];
       // UIImage *profPicImage = profPic2.image;
    //[cell.ProfilePicture setImage:profPicImage];
    
    
        return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // #1 Get the labelSize
    //grab the tweet
    NSDictionary *tweet = [self.allConversations objectAtIndex:indexPath.row];
    //grab the text out of the tweet
    NSString *cellText = [tweet objectForKey:@"message_content"];             //grab the message 
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:15.0];
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
    UIFont *cellFont2 = [UIFont fontWithName:@"Helvetica" size:15.0];
    CGSize constraintSize2 = CGSizeMake(220.0f, MAXFLOAT);
    CGSize labelSize2 = [cellText2 sizeWithFont:cellFont2 constrainedToSize:constraintSize2 lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect temp2 = myLabel.frame;
    temp2.size = labelSize2;
    myLabel.frame = temp2;    
    // #3 Call sizeToFit method
    [myLabel sizeToFit];                                                    //myLabel sizeToFit
    
    
    //NSLog(@"this is what labelSize was before: %lf",labelSize.height);
    //NSLog(@"Predicted cell height:  %lf",myLabel.frame.size.height);
    return 55 + myLabel.frame.size.height;
}








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
                                              //[self loadProfilePictures];
                                              [self messagesDownloadStart]; //1 of 4 Begins background message downloads
                                              
                                          } 
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                              //else you cant connect, therefore push modalview login onto the stack
                                              
                                          }];
    }

    
    
}

//this method has been skipped
-(void)loadProfilePictures
{
    for(int i =0; i < [allConversations count]; i++)
    {
        //load images
        NSDictionary *tweet = [self.allConversations objectAtIndex:i];
        NSString *picURL = [tweet objectForKey: @"profilePic"];
        UIImageView *profPic2 = [[UIImageView alloc]init];
        [profPic2 setImageWithURL:[NSURL URLWithString:picURL]];
        NSLog(@"///////////////////////////////////////////////////////////////////////////////////////////////////");
        NSLog(@"picurl is %@", picURL);
        //append the image to the array
        [self.listOfImages addObject:profPic2];
    }
    [self.tableView reloadData];
}

//this method will start downloading messages for each conversation displayed in community
-(void) messagesDownloadStart //2 of 4
{
    NSLog(@"You have called the databaseDownload method in the Community.m class");
    
    //for each conversation go call getMessages Method which will start downloading data (messages)
    for(int i = 0; i < [allConversations count]; i++)
    {
        //grab the conversation ID 
        NSDictionary *temp = [allConversations objectAtIndex:i];
        NSString * convoID = [temp objectForKey:@"conversation_id"];
        NSLog(@"The conversaion IDs that you are viewing in this tableview are: %@",convoID);
        
        //if(i == 0) //debugging purposes (just to see what messages are in the first displayed convo)
        //get the messages
        [self getMessages:convoID];
        
        
    }
     
}

//this method gets called for each conversation (expecting convoMessages to have the dictionarys to populate
-(void) messagesDownloadFinish  //4 of 4
{
    NSLog(@"You have called databaseDownloadFInish");
    NSLog(@"the length of convoMessages is: %i", [self.convoMessages count]);   
    
    //Store the message into the database
    for(int i = 0; i < [self.convoMessages count]; i++)
    {
        NSDictionary *aMessage = [self.convoMessages objectAtIndex:i];
        
        
        BIDAppDelegate * appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        Message *messageTable = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        
        //only if messageID doesn't already exist then do the save
        //query messageTable and see if messageID already exists
        
        //set up fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        //set the predicate (Message.where(:messageID => messageID) )
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"messageID == %@", aMessage[@"id"]];
        [fetchRequest setPredicate:predicate];
        
        //execute fetchrequest
        NSError *error;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        
        //if execute fetchrequest returns array of 0, then you can run the below statements
        NSLog(@"the number of results gotten back from the query is: %i", [results count]);
        if([results count] == 0)
        {
        messageTable.conversationID =  aMessage[@"conversation_id"]; //[aMessage objectForKey:@"conversation_id"];
            
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZ"];
        NSDate *myDate = [df dateFromString: aMessage[@"created_at"]];
        messageTable.createdAt = myDate;
            
        messageTable.fullName = aMessage[@"full_name"]; 
        messageTable.messageContent = aMessage[@"message_content"];
        messageTable.messageID = aMessage[@"id"];
        messageTable.profilePic = aMessage[@"profilePic"];
        
        NSDate *myDate2 = [df dateFromString: aMessage[@"updated_at"]];
        messageTable.updatedAt = myDate2;
            
        messageTable.userID = aMessage[@"user_id"];
        messageTable.userName = aMessage[@"userName"];
        
        //SAVE
        
        if (![context save:&error])
            {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
    }
    
}

//grab all the messages for a given conversation ID
-(void) getMessages: (NSString *) convoID //3 of 4
{
    //NSMutableArray *convoMessages;
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    //NSLog(@"The value of conversationID is %i", conversationID);
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            convoID, @"conversationID",
                            nil];
    [[AFChattyAPIClient sharedClient] getPath:@"/get_message/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          _convoMessages = responseObject;
                                          NSLog(@"This is the response I recieved: %@", responseObject);
                                          [self messagesDownloadFinish];
                                          
                                          
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
        
}



@end
