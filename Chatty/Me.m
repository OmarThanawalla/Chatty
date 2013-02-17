//
//  top150.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Me.h"
#import "Conversation.h"
#import "ConversationMe.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"
#import "AFChattyAPIClient.h"
#import "CustomMessageCell.h"

#import "Message.h" //this is for CoreData

#import "BIDAppDelegate.h" //This is for CoreData: in order to grab the managedObjectContext
#import <QuartzCore/QuartzCore.h> //This is for accessing layer properties in ProfilePicture to curve the image


@implementation Me

@synthesize conversations;
@synthesize convoMessages;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
    //refresh the data when the view loads
    //[self refresh];
    [TestFlight passCheckpoint:@"Me Class: User loaded the Me conversations view"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Set up colors
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:48.0/256.0 green:49.0/256.0 blue:50.0/256.0 alpha:1.0];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"] forBarMetrics:UIBarMetricsDefault];
    //change tableview Image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    //change the outlining of cells font
    [self.tableView setSeparatorColor: [UIColor colorWithRed:224.0/256.0 green:224.0/256.0 blue:224.0/256.0 alpha:1.0]];
    
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
    return [conversations count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //begin new type of cell placementing
    static NSString *CellIdentifier = @"CustomCellIdentifier";
    static BOOL nibsRegistered = NO;
    if(!nibsRegistered)
    {
        UINib *nib = [UINib nibWithNibName:@"CustomMessageCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        //nibsRegistered = YES;
    }
    
    CustomMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    
    NSDictionary *tweet = [self.conversations objectAtIndex:indexPath.row];
    
    //load Profile Picture
    NSString *picURL = [tweet objectForKey: @"profilePic"];
    [cell.ProfilePicture setImageWithURL:[NSURL URLWithString:picURL]];
    
    //set cell to white color
    [cell setBackgroundColor:[UIColor whiteColor]];

    
    //MessageUser Label
    CGRect labelFrame = CGRectMake(72.0f, 31.0f, 225.0f, 21.0f);
    UILabel *myLabel = [[UILabel alloc] initWithFrame:labelFrame];  //initialize the label
    
    
    myLabel.font =[UIFont systemFontOfSize:13];
    myLabel.lineBreakMode = NSLineBreakByWordWrapping;
    myLabel.numberOfLines = 0;                             //As many lines as it needs
    [myLabel setBackgroundColor:[UIColor whiteColor]];   //For debugging purposes
    myLabel.tag = 1;
    //Create Label Size
    NSString *cellText = [tweet objectForKey:@"message_content"];   //grab the message 
    UIFont *cellFont = [UIFont systemFontOfSize:13];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);           //This sets how wide we can go
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    //Apend the labelSize and call sizeToFit
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
    }
    if(cell.MessageUser != NULL){
        [cell.MessageUser removeFromSuperview];         //remove the old label before putting the new one in
        cell.MessageUser = myLabel;
        [cell.contentView addSubview:cell.MessageUser];
    }

    //set the messageID on the cell
    cell.messageID = tweet[@"id"];
    
    cell.SenderUser.text = [tweet objectForKey:@"full_name"];
    
    //Recipients Label
    cell.Recipients.text = [tweet objectForKey:@"recipient"];
    //grab recipients frame so i can modify it's height
    CGRect temp2 = cell.Recipients.frame;
    temp2.origin.x = 72;
    int messageHeight = myLabel.frame.size.height;
    temp2.origin.y = 35 + messageHeight; //this is what i have to calculate        
    cell.Recipients.frame = temp2;

    //userName label
    cell.userName.text = [tweet objectForKey:@"userName"];
    //NSLog(@"actual cell height %lf",cell.frame.size.height);
   
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
    NSDictionary *tweet = [self.conversations objectAtIndex:indexPath.row];
    
    NSString *cellText = [tweet objectForKey:@"message_content"];   //grab the message
    UIFont *cellFont = [UIFont systemFontOfSize:13];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);           //This sets how wide we can go
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    int dynamicHeight = labelSize.height; //height of MessageUser label
    
    int totalHeight = topSectionHeight + dynamicHeight + bottomSectionHeight;
    
    return totalHeight;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tweet = [conversations objectAtIndex:indexPath.row];
    NSString *convoID = [tweet objectForKey:@"conversation_id"];
    NSString *preAddressing = [tweet objectForKey:@"preAddressing"];
    NSDictionary * setupMaterial = @{ @"convoID" : convoID, @"preAddressing" : preAddressing};
    
    [self performSegueWithIdentifier:@"ShowMyMessages" sender:setupMaterial];
    
    }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowMyMessages"]) {
        ConversationMe *myMessagesView = [segue destinationViewController];
        myMessagesView.currentView = 0;
        myMessagesView.conversationID = sender[@"convoID"];
        myMessagesView.preAddressing = sender[@"preAddressing"];
    }
}

-(IBAction)callToRefresh
{
    [TestFlight passCheckpoint:@"Me Class: User hit the refresh button"];
    //clear the icon because user hit the refresh button
    [[[[self.tabBarController tabBar] items]objectAtIndex:1] setBadgeValue:@"0"];
    //self.tabBarController.tabBarItem.badgeValue = nil;
    [self refresh];
}
//pull a list of the 20ish most recent conversations for the user
-(IBAction)refresh
{
    //[[[[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:@"refreshed"];
    NSLog(@"you hit the refresh button////////////////////////////////////");
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [[AFChattyAPIClient sharedClient] getPath:@"/my_conversation/" parameters:params 
     //if login works, log a message to the console
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                     NSLog(@"Response: %@", responseObject);
                     //rmr: responseObject is an array where each element is a diciontary
                     conversations = responseObject;
                     [self.tableView reloadData];
                     [self messagesDownloadStart]; //1 of 4 Begins background message downloads
                     
                 } 
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     //NSLog(@"Error from postPath: %@",[error localizedDescription]);
                     //else you cant connect, therefore push modalview login onto the stack
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 }];
    

}

-(void) messagesDownloadStart //2 of 4
{
    NSLog(@"You have called the databaseDownload method in the Community.m class");
    
    //for each conversation go call getMessages Method which will start downloading data (messages)
    for(int i = 0; i < [conversations count]; i++)
    {
        //grab the conversation ID
        NSDictionary *temp = [conversations objectAtIndex:i];
        NSString * convoID = [temp objectForKey:@"conversation_id"];
        NSLog(@"The conversaion IDs that you are viewing in this tableview are: %@",convoID);
        
        //if(i == 0) //debugging purposes (just to see what messages are in the first displayed convo)
        //get the messages
        [self getMessages:convoID];
        
        
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
                                          convoMessages = responseObject;
                                          NSLog(@"This is the response I recieved: %@", responseObject);
                                          [self messagesDownloadFinish];
                                          
                                          
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
    
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
            messageTable.likesCount = [NSString stringWithFormat:@"%@", aMessage[@"likes"]];
            NSLog(@"There is an update: %@",aMessage[@"hasBeenLiked"]);
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
            NSLog(@"There is an update: %@",aMessage[@"hasBeenLiked"]);
            if (![context save:&error])
            {
                NSLog(@"Whoops, couldn't save the updation of likesCount: %@", [error localizedDescription]);
            }
            
            
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
