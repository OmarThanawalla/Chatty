//
//  top150.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Me.h"
#import "Conversation.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"
#import "AFChattyAPIClient.h"
#import "CustomMessageCell.h"

@implementation Me
@synthesize conversations;


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
    //refresh the data when the view loads
    //[self refresh];
    

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
    
    
    NSDictionary *tweet = [self.conversations objectAtIndex:indexPath.row];
    
    
    //MessageUser Label
    CGRect labelFrame = CGRectMake(72.0f, 26.0f, 0.0f, 0.0f);   
    UILabel *myLabel = [[UILabel alloc] initWithFrame:labelFrame];  //initialize the label
    
    myLabel.text = [tweet objectForKey:@"message_content"];
    myLabel.font =[UIFont systemFontOfSize:15];
    myLabel.lineBreakMode = UILineBreakModeWordWrap;
    myLabel.numberOfLines = 0;                             //As many lines as it needs
    [myLabel setBackgroundColor:[UIColor clearColor]];   //For debugging purposes
    myLabel.tag = 1;
    //Create Label Size
    NSString *cellText = [tweet objectForKey:@"message_content"];   //grab the message 
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:15.0];
    CGSize constraintSize = CGSizeMake(225.0f, MAXFLOAT);           //This sets how wide we can go
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    //Apend the labelSize and call sizeToFit
    CGRect temp = myLabel.frame;
    temp.size = labelSize;
    myLabel.frame = temp;                                  //so origin x,y should stil be in tact
    NSLog(@"%@", myLabel.text);
     NSLog(@"%@", myLabel.frame.size.height);
    [myLabel sizeToFit];
    NSLog(@"actual height: %@", myLabel.frame.size.height);
    //Adding the label to the view
    if(cell.MessageUser == NULL){
        cell.MessageUser = myLabel;
        [cell.contentView addSubview:cell.MessageUser];
    }else{
        [cell.MessageUser removeFromSuperview];         //remove the old label before putting the new one in
        cell.MessageUser = myLabel;
        [cell.contentView addSubview:cell.MessageUser];
    }

    
    
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

    return cell;
    

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tweet = [self.conversations objectAtIndex:indexPath.row];
    
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
    NSLog(@"Predicted cell height:  %lf",myLabel.frame.size.height);
    return 55 + myLabel.frame.size.height;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tweet = [conversations objectAtIndex:indexPath.row];
    NSString *convoID = [tweet objectForKey:@"conversation_id"];
    [self performSegueWithIdentifier:@"ShowMyMessages" sender:convoID];
    
    }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowMyMessages"]) {
        Conversation *myMessagesView = [segue destinationViewController];
        myMessagesView.currentView = 0;
        myMessagesView.conversationID = sender;
    }
}

//pull a list of the 20ish most recent conversations for the user
-(IBAction)refresh
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            nil];
    
    [[AFChattyAPIClient sharedClient] getPath:@"/my_conversation/" parameters:params 
     //if login works, log a message to the console
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                     NSLog(@"Response: %@", responseObject);
                     //rmr: responseObject is an array where each element is a diciontary
                     conversations = responseObject;
                     [self.tableView reloadData];
                    
                     
                 } 
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error from postPath: %@",[error localizedDescription]);
                     //else you cant connect, therefore push modalview login onto the stack
                 }];
    

}




@end
