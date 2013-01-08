//
//  conversationTop60.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Conversation.h"
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
#import "KeychainItemWrapper.h"
#import "CustomMessageCell.h"
#import "composeMessageOnly.h"

#import "BIDAppDelegate.h" //This is for CoreData: in order to grab the managedObjectContext
#import "Message.h"

@implementation Conversation

@synthesize currentView;
@synthesize conversationID;
@synthesize messages;
@synthesize preAddressing;
@synthesize convoMessages;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //make messages an empty array
        
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
   
    //change tableview Image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    //create NSIndexPath
    //NSIndexPath * tempIndexPath = [NSIndexPath indexPathForRow:([messages count]-1) inSection:0];
    
    //SCROLL to the bottom
    //[self.tableView scrollToRowAtIndexPath:tempIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //Set up Listener pattern
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyAction:) name:@"composeMessageOnly" object:nil];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //refresh the data on view loading
    
    //[self refresh];
    // We're going to pull our data from the database
    [self loadFromDatabase];
}

-(void)loadFromDatabase
{
    BIDAppDelegate * appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //set the predicate (all messages that are in conversationID)
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationID == %@", self.conversationID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"The number of messages that were found were: %i", [fetchedObjects count]);
    
    self.messages = fetchedObjects;
    [self.tableView reloadData];
}

//0 The submit button on composeMessageOnly was hit
-(void)anyAction:(NSNotification *)anote
{
    NSLog(@"anyAction method fired. presumably from composeMessageOnly submit button being hit");
    [self refreshTheDatabase];
}

//1 Kickoff method
-(void)refreshTheDatabase
{
    NSLog(@"You hit the refreshTheDatabase method in Conversation.m file");
    //update the database with information from the server
    [self getMessages:conversationID];
}

//2 Get new content
-(void) getMessages: (NSString *) convoID
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
                                          convoMessages = responseObject;
                                          NSLog(@"This is the response I recieved: %@", responseObject);
                                          [self saveToDatabase];
                                          
                                          
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
    
}
//3 Save Content to Database
-(void) saveToDatabase  //3
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
    //and then call loadFromDatabase
    [self loadFromDatabase]; //4
}




- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData]; 
    
    //scroll to the bottom of the messages (YOU HAVE TO initialze messages to 0 because it takes a few seconds on the iphone)
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messages count]-1 inSection:0 ];
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    /*
    //iterate the first cell and find all the @targets
    NSIndexPath *firstCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    CustomMessageCell *myFirstCell = (CustomMessageCell*)[self.tableView cellForRowAtIndexPath:firstCellIndex];
    NSString *message =  myFirstCell.MessageUser.text;
    NSArray *messageArray = [message componentsSeparatedByString: @" "];
    NSLog(@"%@",messageArray);
    //this string will hold the usernames while we iterate
    NSMutableString *userNames = [[NSMutableString alloc] init];
    */
    /*
    //iterate through the messageArray
    for(int i = 0; i < messageArray.count; i++)
    {
        //grab the element out of the array
        NSString *element = [messageArray objectAtIndex:i];
        //grab the first char of this element
        NSString *subStringFirstChar;
        if(element.length > 1)
        {
            subStringFirstChar = [element substringWithRange:NSMakeRange(0, 1)];
        }else {
            //handles one character long excpetions
            subStringFirstChar = element;
            NSLog(@"length less than one");
        }
        if([subStringFirstChar isEqualToString:@"@"]) //asks: is the first character an @ ?
        {
            //concatenate this word to the list of usernames
            [userNames appendString:element];
            [userNames appendString:@" "];
        }
    }
    */
    
    //assign usernames to the preAddressing variable where we will set it to destinationViewController upon prepareForSegueMethod
   // preAddressing = userNames;
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
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *CellIdentifier = @"CustomCellIdentifier";
        static BOOL nibsRegistered = NO;
        if(!nibsRegistered)
        {
            UINib *nib = [UINib nibWithNibName: @"CustomMessageCell" bundle:nil];//grab the nib
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];//register nib
            //nibsRegistered = YES; //this line commented out on purpose
        }
        
        CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
        
            Message * myMessage = [self.messages objectAtIndex:indexPath.row];
            //MessageUser Label
            CGRect labelFrame = CGRectMake(72.0f, 26.0f, 0.0f, 0.0f);   
            UILabel *myLabel = [[UILabel alloc] initWithFrame:labelFrame];  //initialize the label
            
            myLabel.text = myMessage.messageContent; //[tweet objectForKey:@"message_content"];
            myLabel.font =[UIFont systemFontOfSize:13];
            myLabel.lineBreakMode = UILineBreakModeWordWrap;
            myLabel.numberOfLines = 0;
            [myLabel setBackgroundColor:[UIColor clearColor]];
            myLabel.tag = 1;
            //Create Label Size
            NSString *cellText = myMessage.messageContent; //[tweet objectForKey:@"message_content"];   //grab the message
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
        cell.SenderUser.text = myMessage.fullName; //[tweet objectForKey:@"full_name"];
    
        //Remove recipients label
        [cell.Recipients removeFromSuperview];
        cell.userInteractionEnabled = NO;
        cell.userName.text = myMessage.userName; //[tweet objectForKey:@"userName"];
    
        //load Profile Picture
        NSString *picURL = myMessage.profilePic; //[tweet objectForKey: @"profilePic"];
        //NSLog(@"The url for the pic is: %@", picURL);
        [cell.ProfilePicture setImageWithURL:[NSURL URLWithString:picURL]];
    
        return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message * myMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *cellText = myMessage.messageContent;             //grab the message 
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
    NSString *cellText2 = myMessage.messageContent;
    UIFont *cellFont2 = [UIFont fontWithName:@"Helvetica" size:15.0];
    CGSize constraintSize2 = CGSizeMake(220.0f, MAXFLOAT);
    CGSize labelSize2 = [cellText2 sizeWithFont:cellFont2 constrainedToSize:constraintSize2 lineBreakMode:UILineBreakModeWordWrap];
    
    CGRect temp2 = myLabel.frame;
    temp2.size = labelSize2;
    myLabel.frame = temp2;    
    // #3 Call sizeToFit method
    [myLabel sizeToFit];    
    
    double total = 0 + myLabel.frame.size.height;
    return (total > 70 ? total : 70);
}    

#pragma mark - Table view delegate


-(void) refresh
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    //NSLog(@"The value of conversationID is %i", conversationID);
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            self.conversationID, @"conversationID",
                            nil];
    [[AFChattyAPIClient sharedClient] getPath:@"/get_message/" parameters:params 
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          self.messages = responseObject;
                                          NSLog(@"This is the response I recieved in the message view: %@", responseObject);
                                          [self.tableView reloadData];

                                          
                                          
                                      } 
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender 
{
    
    if ([segue.identifier isEqualToString:@"writeMessage"]) 
    {
        composeMessageOnly *myMessageWriter = [segue destinationViewController];
        myMessageWriter.conversationID = self.conversationID;
        myMessageWriter.preAddressing = self.preAddressing;
        
        
    }
}





@end
