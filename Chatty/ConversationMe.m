//
//  ConversationMe.m
//  Chatty
//
//  Created by Omar Thanawalla on 10/25/12.
//
//

#import "ConversationMe.h"
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
#import "KeychainItemWrapper.h"
#import "CustomMessageCell.h"
#import "composeMessageOnly.h"

#import "BIDAppDelegate.h" //This is for CoreData: in order to grab the managedObjectContext
#import "Message.h"

#import <QuartzCore/QuartzCore.h> //This is for accessing layer properties in ProfilePicture to curve the image


@interface ConversationMe ()

@end

@implementation ConversationMe

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //change tableview Image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    NSLog(@"////////////////////////////////////////////////////////////////////////");
    NSLog(@"refresh method called");
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
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
            messageTable.hasBeenLiked = aMessage[@"hasBeenLiked"];
            messageTable.likesCount = [NSString stringWithFormat:@"%@", aMessage[@"likes"]];
            NSLog(@"The value of likesCount is: %@", [NSString stringWithFormat:@"%@", aMessage[@"likes"]]);
            
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
            NSLog(@"There has been an update");
            if (![context save:&error])
            {
                NSLog(@"Whoops, couldn't save the updation of likesCount: %@", [error localizedDescription]);
            }
            
            
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //and then call loadFromDatabase
    [self loadFromDatabase]; //4
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
    /*
    //scroll to the bottom of the messages
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messages count]-1 inSection:0 ];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    NSIndexPath *firstCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    CustomMessageCell *myFirstCell = (CustomMessageCell*)[self.tableView cellForRowAtIndexPath:firstCellIndex];
    NSString *message =  myFirstCell.MessageUser.text;
    NSArray *messageArray = [message componentsSeparatedByString: @" "];
    
    //this string will hold the usernames while we iterate
    NSMutableString *userNames = [[NSMutableString alloc] init];
    
    //iterate through the messageArray
    
    //FIX THIS CODE BECAUSE IT THROWS UP EXCEPTIONS
    
    for(int i = 0; i < messageArray.count; i++)
    {
        //grab the element out of the array
        NSString *element = [messageArray objectAtIndex:i];
        //grab the first char of this element
        NSString *subStringFirstChar = [element substringWithRange:NSMakeRange(0, 1)];
        if([subStringFirstChar isEqualToString:@"@"]) //is the first character an @
        {
            //concatenate this word to the list of usernames
            [userNames appendString:element];
            [userNames appendString:@" "];
        }
    }
    
        
    //assign usernames to the preAddressing variable where we will set it to destinationViewController upon prepareForSegueMethod
    preAddressing = userNames;
    */
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Message * myMessage = [self.messages objectAtIndex:indexPath.row];
    
    //load profile pic
    NSString *picURL = myMessage.profilePic;
    [cell.ProfilePicture setImageWithURL:[NSURL URLWithString:picURL]];
    
    //MessageUser Label
            CGRect labelFrame = CGRectMake(72.0f,31.0f, 225.0f, 21.0f);    
            UILabel *myLabel = [[UILabel alloc] initWithFrame:labelFrame];  //initialize the label
            
            myLabel.text = myMessage.messageContent;
            myLabel.font =[UIFont systemFontOfSize:13];
            myLabel.lineBreakMode = NSLineBreakByWordWrapping;
            myLabel.numberOfLines = 0;                             //As many lines as it needs
            [myLabel setBackgroundColor:[UIColor whiteColor]];   //For debugging purposes
            myLabel.tag = 1;
            //Create Label Size
            NSString *cellText = myMessage.messageContent;   //grab the message 
            UIFont *cellFont = [UIFont systemFontOfSize:13];
            CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);           //This sets how wide we can go
            CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            
            //Apend the labelSize
            CGRect temp = myLabel.frame;
            temp.size = labelSize;
            myLabel.frame = temp;                                  //so origin x,y should stil be in tact
     
            
            //Adding the label to the view
            if(cell.MessageUser == NULL){
                cell.MessageUser = myLabel;
                [cell.contentView addSubview:cell.MessageUser];
            }else{
                [cell.MessageUser removeFromSuperview];         //remove the old label before putting the new one in
                cell.MessageUser = myLabel;
                [cell.contentView addSubview:cell.MessageUser];
            }
    //set the messageID on the cell
    cell.messageID = [myMessage.messageID stringValue];
    
    //SenderUser Label
    cell.SenderUser.text = myMessage.fullName;
    
    //likesCounter: give it value and position it on the cell
    cell.cumulativeLikes.text = [NSString stringWithFormat:@"%@", myMessage.likesCount];
    CGRect temp2 = cell.cumulativeLikes.frame;
    int messageUserHeight = temp.size.height; //makes use of labelSize calcluates above (temp.frame)
    temp2.origin.y = 30 + messageUserHeight;
    temp2.origin.x = 279;
    cell.cumulativeLikes.frame = temp2;
    
    //like button: position it on the cell
    CGRect temp3 = cell.likeButton.frame;
    temp3.origin.y = 24 + messageUserHeight;
    cell.likeButton.frame = temp3;
    
    //Remove recipients label
    [cell.Recipients removeFromSuperview];
    
    //userName label
    cell.userName.text = myMessage.userName;
    
    //tell the cell if the user has liked this message before
    NSNumber * myNumber = myMessage.hasBeenLiked;
    NSLog(@"The value for bool is: %@", myNumber);
    [cell isLike:myNumber];
    
    //ProfilePicture: round corners
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
    int bottomSectionHeight = 25; //height of Recipients Label and bottom border
    
    Message * myMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *cellText = myMessage.messageContent;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

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
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
