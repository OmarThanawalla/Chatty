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

#import <QuartzCore/QuartzCore.h> //This is for accessing layer properties in ProfilePicture to curve the image
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
    //self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:48.0/256.0 green:49.0/256.0 blue:50.0/256.0 alpha:1.0];
    
    //flatten image
    [[[self tabBarController] tabBar] setBackgroundImage:[UIImage imageNamed:@"tabbar.png"]];
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"] forBarMetrics:UIBarMetricsDefault];
    
    //change tableview Image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    

    //setting currentView to 1 here because I removed the toggling of AllConvo's and FavoriteConvo's
    self.currentView = 1;
    
    
    //[self performSegueWithIdentifier:@"composeAConvo" sender:self];
    [self.tabBarController setSelectedIndex:3];
    
    //set tableView seperator colors
    [self.tableView setSeparatorColor: [UIColor colorWithRed:224.0/256.0 green:224.0/256.0 blue:224.0/256.0 alpha:1.0]];
    
    //set up listener pattern
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyAction:) name:@"likeButtonDepressed" object:nil];
    
    
    [self refresh];
    //[self deleteEverything];
   
}

-(void) deleteEverything
{
    NSLog(@"You ran the deleteEverything method");
    BIDAppDelegate * appDelegate = (BIDAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    	NSLog(@"%@ object deleted",@"Message");
    }
    if (![context save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",@"Message",error);
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
    NSLog(@"viewWillAppear");
    //Set up Listener pattern
    //community tableview is in view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyAction:) name:@"likeButtonDepressed" object:nil];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"likeButtonDepressed" object:nil]; //will not respond if like button is pushed on the cell, when the cell is from another viewcontroller

}

//when the like button is hit this method will fire
-(void)anyAction:(NSNotification *)anote
{
    NSLog(@"anyAction method fired. LIKE button was hit in community tab, community.m view");
    // disabled this because we ended up just updating the number on the box
    //[self refresh];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    
    
        //load Profile Picture
        NSString *picURL = [tweet objectForKey: @"profilePic"];
        NSLog(@"The url for the pic is: %@", picURL);
        [cell.ProfilePicture setImageWithURL:[NSURL URLWithString:picURL]];
    
    
            //MessageUser Label: Calculate Dimensions
            CGRect labelFrame = CGRectMake(72.0f, 31.0f, 225.0f, 21.0f);//this is saying no width and no height
            UILabel *myLabel = [[UILabel alloc] initWithFrame:labelFrame];  //initialize the label
            
            
            myLabel.font =[UIFont systemFontOfSize:13];
            myLabel.lineBreakMode = NSLineBreakByWordWrapping; // "Wrap or clip the string only at word boundaries. This is the default wrapping option"
            myLabel.numberOfLines = 0;                             //As many lines as it needs
            [myLabel setBackgroundColor:[UIColor whiteColor]];   //For debugging purposes
            myLabel.tag = 1;
            //Create Label Size
            NSString *cellText = [tweet objectForKey:@"message_content"];   //grab the message
            UIFont *cellFont = [UIFont systemFontOfSize:13];
            CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);           //This sets how wide we can go
            CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            
           //Apend the labelSize 
            CGRect temp = myLabel.frame;
            temp.size = labelSize;
            myLabel.frame = temp;                                  //so origin x,y should stil be in tact
            //[myLabel sizeToFit];
    
            //assign text into the label
            myLabel.text = [tweet objectForKey:@"message_content"];
    
    
            //Adding the label to the view
            if(cell.MessageUser == NULL){
                cell.MessageUser = myLabel;
                [cell.contentView addSubview:cell.MessageUser];
            }else
            {
                [cell.MessageUser removeFromSuperview];         //remove the old label before putting the new one in
                cell.MessageUser = myLabel;
                [cell.contentView addSubview:cell.MessageUser];
            }
    
    
        //set the messageID on the cell
        cell.messageID = tweet[@"message_id"];
    
        //SenderUser Label
        cell.SenderUser.text = [tweet objectForKey:@"full_name"];
        
        //Recipients Label
        cell.Recipients.text = [tweet objectForKey:@"recipient"];
        //grab recipients frame so i can modify it's height
        CGRect temp2 = cell.Recipients.frame;
        temp2.origin.x = 72;
        int messageHeight = myLabel.frame.size.height;
        temp2.origin.y = 35 + messageHeight; //35 is distance between top of cell and messageUserLabel, and messageHeight is the height of the messageUserLabel        
        cell.Recipients.frame = temp2;
        
        //userName label
        cell.userName.text = [tweet objectForKey:@"userName"];
    
        //Number of Likes: on cell and position it 
        cell.cumulativeLikes.text = [NSString stringWithFormat:@"%@",[tweet objectForKey:@"likes"]];
        CGRect temp5 = cell.cumulativeLikes.frame;
        int messageUserHeight = temp.size.height; //makes use of labelSize calcluates above (temp.frame)
        temp5.origin.y = 30 + messageUserHeight;
        temp5.origin.x = 279; //temp5.origin.x - 3;
        cell.cumulativeLikes.frame = temp5;
    
        //Like Button: position it on the cell
        CGRect temp3 = cell.likeButton.frame;
        temp3.origin.y = 32 + messageUserHeight;
        cell.likeButton.frame = temp3;
        
    
        //tell the cell if the user has liked this message before
        NSNumber * myNumber = tweet[@"hasBeenLiked"];
        [cell isLike:myNumber];
    
       // UIImageView * profPic2 = [self.listOfImages objectAtIndex:indexPath.row];
       // UIImage *profPicImage = profPic2.image;
    //[cell.ProfilePicture setImage:profPicImage];
        cell.ProfilePicture.layer.cornerRadius = 9.0;
        cell.ProfilePicture.layer.masksToBounds = YES;
        cell.ProfilePicture.layer.borderColor = [UIColor blackColor].CGColor;
        cell.ProfilePicture.layer.borderWidth = 0.0;
        CGRect frame = cell.ProfilePicture.frame;
        frame.size.height = 50;
        frame.size.width = 50;
        cell.ProfilePicture.frame = frame;
        return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int topSectionHeight = 27; //height of SenderUser Label and top border
    int bottomSectionHeight = 32; //height of Recipients Label and bottom border
    
    //Begin calculation of the variable height that is MessageUser
    NSDictionary *tweet = [self.allConversations objectAtIndex:indexPath.row];
    
    NSString *cellText = [tweet objectForKey:@"message_content"];   //grab the message
    UIFont *cellFont = [UIFont systemFontOfSize:13];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);           //This sets how wide we can go
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    int dynamicHeight = labelSize.height; //height of MessageUser label
    
    int totalHeight = topSectionHeight + dynamicHeight + bottomSectionHeight;
    
    return totalHeight;
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
        NSString *preAddressing = [tweet objectForKey:@"preAddressing"];
        NSDictionary * setupMaterial = @{ @"convoID" : convoID, @"preAddressing" : preAddressing};
        
        
        [self performSegueWithIdentifier:@"ShowMyCommunityMessages" sender:setupMaterial];
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
            //missing dictionary style entry because i dont antiripcate currentview to be 0
        }
        if(currentView == 1)
        {
            messageView.currentView = 1;
            messageView.conversationID = sender[@"convoID"];
            NSLog(@"The conversation set on thhe next view will be: %@",messageView.conversationID);
            
            messageView.preAddressing = sender[@"preAddressing"];
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
//    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(70, 85, 180, 180)];
//    [activity setBackgroundColor:[UIColor lightGrayColor]];
//    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    [self.view addSubview:activity];
//    
//    [activity startAnimating];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
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
                                              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
                                              //[activity stopAnimating];
                                              
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
        //[aMessage objectForKey:@"preAddressing"];
        
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
        
        //IF RECORD EXISTS
        NSLog(@"the number of results gotten back from the query is: %i", [results count]);
        if([results count] == 0)
        {
            //CREATE A NEW RECORD
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
            messageTable.likesCount = [NSString stringWithFormat:@"%@", aMessage[@"likes"]];
            messageTable.hasBeenLiked = aMessage[@"hasBeenLiked"];
            //SAVE
            
            if (![context save:&error])
                {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
            
        }
        
        //else you should update the found object sitting in results array and update the likes columns
        
        else
        {
         //UPDATE RECORD: by grabbing the object and updating it
          Message * myMessage =[results objectAtIndex:0];
          myMessage.likesCount = [NSString stringWithFormat:@"%@", aMessage[@"likes"]];
          myMessage.hasBeenLiked = aMessage[@"hasBeenLiked"];
            
            if (![context save:&error])
            {
                NSLog(@"Whoops, couldn't save the updation of likesCount: %@", [error localizedDescription]);
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
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                          
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
        
}



@end
