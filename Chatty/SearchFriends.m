//
//  SearchFriends.m
//  Chatty
//
//  Created by Omar Thanawalla on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchFriends.h"
#import "UserCell.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"
#import "AFChattyAPIClient.h"

@interface SearchFriends ()

@end

@implementation SearchFriends
@synthesize searchQuery;
@synthesize listOfUsers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//table view delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return [listOfUsers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"UserCell";
    static BOOL nibsRegistered = NO;
    if(!nibsRegistered)
    {
        UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        //nibsRegistered = YES;
    }
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    

    //configure cell here
    NSDictionary * tweet = [listOfUsers objectAtIndex:indexPath.row];
    NSString *firstName = [tweet objectForKey:@"first_name"];
    NSString *lastName = [tweet objectForKey:@"last_name"];
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    cell.bio.text = [tweet objectForKey:@"Bio"];
    cell.userID = [tweet objectForKey:@"id"];
    
    //set the state and image of the cell
    NSString *relationship = [tweet objectForKey:@"is_friend"];
    NSLog(@"Cell for row at index path has been called again, the value for relationship is %@", relationship);
    if ([relationship isEqualToString:@"YES"]) 
    {
        NSLog(@"You have assigned the value to 1");
        cell.requestSent = 1;
        UIImage *btnImage = [UIImage imageNamed:@"green-checkmark.png"];
        [cell.requestButton setImage:btnImage forState:UIControlStateNormal];
        
    }
    if ([relationship isEqualToString:@"NO"]) 
    {
        NSLog(@"You have assigned the value to 0");
        cell.requestSent = 0;
        UIImage *btnImage = [UIImage imageNamed:@"bluePlusSign.jpeg"];
        [cell.requestButton setImage:btnImage forState:UIControlStateNormal];
        

    }
    
    
    return cell;
}



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.searchQuery = searchString;

    //keep the table cleared until I hit submit
    self.listOfUsers = nil;
    [self.searchDisplayController.searchResultsTableView reloadData];
    return NO;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"The search button has been clicked. here is the query %@", searchQuery);
    //get search results using afnetworking, it will also handle reloading the search table
    [self refresh];
}

-(void)refresh
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            self.searchQuery, @"searchQuery",
                            nil];
    
    [[AFChattyAPIClient sharedClient] getPath:@"/search_user/" parameters:params 
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          NSLog(@"Response: %@", responseObject);
                                                //set the list of users here
                                          self.listOfUsers = responseObject;
                                                //refresh the table
                                          [self.searchDisplayController.searchResultsTableView reloadData];
                                          
                                          
                                      } 
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from SearchFriends: %@",[error localizedDescription]);
                                      }];
    
    
}



@end
