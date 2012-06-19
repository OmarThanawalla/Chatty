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
    NSLog(@"The convo id i have been initialzed to is : %@", conversationID);
    
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
    return 4; //[messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
            static NSString *CellIdentifier = @"CustomCellIdentifier";
            static NSString *JasonKidd = @"JasonKidd";
            static NSString *JasonTerry = @"JasonTerry";
            static NSString *MarkC = @"MarkCuban";
        static BOOL nibsRegistered = NO;
        if(!nibsRegistered)
        {
            if (indexPath.row == 0) {
                
                UINib *nib = [UINib nibWithNibName: @"CustomMessageCell" bundle:nil];//grab the nib
                [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];//register nib
                //nibsRegistered = YES; //this line commented out on purpose
                CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                NSDictionary *aMessage = [self.messages objectAtIndex:indexPath.row];
                cell.MessageUser.text = [aMessage objectForKey:@"message_content"];
                cell.SenderUser.text = [aMessage objectForKey:@"full_name"];
                cell.Recipients.text= @"";
                return cell;

            }
            if (indexPath.row == 1) {
                
                UINib *nib = [UINib nibWithNibName: @"JasonTerry" bundle:nil];//grab the nib
                [tableView registerNib:nib forCellReuseIdentifier:JasonTerry];//register nib
                //nibsRegistered = YES; //this line commented out on purpose
                CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:JasonTerry];
                
                cell.MessageUser.text = @"Thas us foolllll";
                cell.SenderUser.text = @"Jason Terry";
                return cell;

            }

            if (indexPath.row == 2) {
                
                UINib *nib = [UINib nibWithNibName: @"JasonKidd" bundle:nil];//grab the nib
                [tableView registerNib:nib forCellReuseIdentifier:JasonKidd];//register nib
                //nibsRegistered = YES; //this line commented out on purpose
                CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:JasonKidd];
                
                cell.MessageUser.text = @"Yo i just left a doobie in Mark's bathroom haha";
                cell.SenderUser.text = @"Jason Kidd";

                return cell;

            }

            if (indexPath.row == 3) {
                
                UINib *nib = [UINib nibWithNibName: @"MarkCuban" bundle:nil];//grab the nib
                [tableView registerNib:nib forCellReuseIdentifier:MarkC];//register nib
                //nibsRegistered = YES; //this line commented out on purpose
                CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:MarkC];
                cell.MessageUser.text = @"Ugh gross. That's it, I'm signing Deron Williams";
                cell.SenderUser.text = @"Mark Cuban";
                
                return cell;

            }

        }
        
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row != 0)
    {
        return 75;
    }
    return 95;
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
        
        
    }
}





@end
