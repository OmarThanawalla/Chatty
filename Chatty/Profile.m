//
//  Profile.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Profile.h"
#import "profileCustomCell.h"
#import "PendingRequestCell.h"
#import "KeychainItemWrapper.h"
//import AFNetworking
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"

@implementation Profile

@synthesize currentView, name, tag;
@synthesize follows;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.currentView = 0;
    
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
    name = [[NSMutableArray alloc] initWithObjects:@"Omar", @"Kathy Lee", @"Britney Spears",@"Kobe Bryant",@"Tony Parker",@"Bill Gates", nil];
    tag = [[NSMutableArray alloc] initWithObjects:@"OT", @"KathyL", @"BritneySpears",@"Kobe",@"TParker",@"BGates", nil];

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
    // profile segment
    if (self.currentView == 0) {
        return 2;
    }
    else //other segmented control
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.currentView == 0) {
        if(section == 0)
        {
            return 1;
        }
        else
        {
            return [follows count];
        }
    } else {
        return [name count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
   
    //profile SEGMENT
    if (self.currentView == 0)
    {
        //profile SECTION
        if (indexPath.section == 0) {

            static NSString *CellIdentifier = @"CellIdentifier";
            static BOOL nibsRegistered = NO;
            if(!nibsRegistered)
            {
                UINib *nib = [UINib nibWithNibName: @"profileCustomCell" bundle:nil];
                [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
                nibsRegistered = YES;
            }
            
            profileCustomCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            cell.BioText.text = @"I live in Austin!";
            cell.NameText.text = @"Omar Thanawall";
            cell.userName.text = @"Batman";
            return cell;
 
        }
        else // you are in the pendingRequestsSection
        {
            NSLog(@"This is section 1");
            static NSString *CellIdentifier = @"PendingCell";
            static BOOL nibsRegistered = NO;
            if(!nibsRegistered)
            {
                UINib *nib = [UINib nibWithNibName: @"PendingRequestCell" bundle:nil];
                [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
                nibsRegistered = YES;
            }
            
            PendingRequestCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            NSDictionary *user = [follows objectAtIndex:indexPath.row];
            
            cell.fullName.text = [user objectForKey:@"fullName"];
            cell.bio.text = [user objectForKey:@"bio"];
            cell.userName.text = [user objectForKey:@"userName"];
            cell.userID = [user objectForKey:@"userID"];
            
            return cell;
        }
        
    } 
    else{
        static NSString *CellIdentifier = @"CellFav";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
        }
        cell.textLabel.text = [name objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [tag objectAtIndex:indexPath.row];
        return cell;
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

- (IBAction)toggleView:(id)sender {
    
    if([sender selectedSegmentIndex] == 1)
    {
        self.currentView = 1;
        [self.tableView reloadData]; 
    } else {
        self.currentView = 0;
        [self.tableView reloadData]; 
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 120.0;
    }
    return 90.0;
}

-(IBAction) logout
{
    //i just had the modal view for login pop up, this way the only way to get back in is to successfully login instead of loggin out
    
//    NSLog(@"logout function called");
//    //clear key chain
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
//    [keychain setObject:@"" forKey:(__bridge id) kSecAttrAccount];
//    [keychain setObject:@"" forKey:(__bridge id)kSecValueData];
//    
//    //send it to the community tab 
//    [self.tabBarController setSelectedIndex:0];
    
}

-(IBAction)refresh
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            nil];

    [[AFChattyAPIClient sharedClient] getPath:@"/follower/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          NSLog(@"Response: %@", responseObject);
                                   
                                          follows = responseObject;
                                          [self.tableView reloadData];
                                          
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                      }];

}

@end
