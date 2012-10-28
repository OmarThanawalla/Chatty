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


@interface ConversationMe ()

@end

@implementation ConversationMe

@synthesize currentView;
@synthesize conversationID;
@synthesize messages;
@synthesize preAddressing;

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
    NSLog(@"this view, conversationMe did load");

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    //refresh the data on view loading
    [self refresh];
    
}



- (void)viewDidAppear:(BOOL)animated
{
//    [super viewDidAppear:animated];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([messages count]-1) inSection:0];
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    NSIndexPath *firstCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    CustomMessageCell *myFirstCell = (CustomMessageCell*)[self.tableView cellForRowAtIndexPath:firstCellIndex];
    NSString *message =  myFirstCell.MessageUser.text;
    NSArray *messageArray = [message componentsSeparatedByString: @" "];
    
    //this string will hold the usernames while we iterate
    NSMutableString *userNames = [[NSMutableString alloc] init];
    
    //iterate through the messageArray
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
    
    NSLog(@"%@",userNames);
    
    //assign usernames to the preAddressing variable where we will set it to destinationViewController upon prepareForSegueMethod
    preAddressing = userNames;
    
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
    NSLog(@"%i", [messages count]);
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
    
    NSDictionary *aMessage = [self.messages objectAtIndex:indexPath.row];
    cell.MessageUser.text = [aMessage objectForKey:@"message_content"];
    cell.SenderUser.text = [aMessage objectForKey:@"full_name"];
    cell.userInteractionEnabled = NO;
    cell.userName.text = [aMessage objectForKey:@"userName"];
    return cell;
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

@end
