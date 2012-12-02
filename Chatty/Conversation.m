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

@implementation Conversation

@synthesize currentView;
@synthesize conversationID;
@synthesize messages;
@synthesize preAddressing;

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
    [super viewDidAppear:animated];
    [self.tableView reloadData]; 
    //taking out the below code because I think it has something to do with my app terminating when viewing a conversation
    //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //iterate the first cell and find all the @targets
    NSIndexPath *firstCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    CustomMessageCell *myFirstCell = (CustomMessageCell*)[self.tableView cellForRowAtIndexPath:firstCellIndex];
    NSString *message =  myFirstCell.MessageUser.text;
    NSArray *messageArray = [message componentsSeparatedByString: @" "];
    NSLog(@"%@",messageArray);
    //this string will hold the usernames while we iterate
    NSMutableString *userNames = [[NSMutableString alloc] init];
    
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
    
    
    //assign usernames to the preAddressing variable where we will set it to destinationViewController upon prepareForSegueMethod
    preAddressing = userNames;
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
            
        NSDictionary *tweet = [self.messages objectAtIndex:indexPath.row];
        
            //MessageUser Label
            CGRect labelFrame = CGRectMake(72.0f, 26.0f, 0.0f, 0.0f);   
            UILabel *myLabel = [[UILabel alloc] initWithFrame:labelFrame];  //initialize the label
            
            myLabel.text = [tweet objectForKey:@"message_content"];
            myLabel.font =[UIFont systemFontOfSize:13];
            myLabel.lineBreakMode = UILineBreakModeWordWrap;
            myLabel.numberOfLines = 0;
            [myLabel setBackgroundColor:[UIColor clearColor]];
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
    
        //Remove recipients label
        [cell.Recipients removeFromSuperview];
        cell.userInteractionEnabled = NO;
        cell.userName.text = [tweet objectForKey:@"userName"];
        return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tweet = [self.messages objectAtIndex:indexPath.row];
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
    [myLabel sizeToFit];    
    
    double total = 0 + myLabel.frame.size.height;
    return (total > 70 ? total : 70);
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





@end
