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
#import "facebookFriendList.h"

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
    self.title = @"Find Friends";
    [TestFlight passCheckpoint:@"Search Friends Class: User is viewing the search users tab"];
    //Set up colors
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:48.0/256.0 green:49.0/256.0 blue:50.0/256.0 alpha:1.0];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"] forBarMetrics:UIBarMetricsDefault];
    
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
//    [tempImageView setFrame:self.view.frame];
//    
//    self.view.backgroundView = tempImageView;
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
    cell.fullName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    //resize the bio label since you are dequeing some of them
    CGRect labelFrame = CGRectMake(68.0f, 21.0f, 211.0f, 41.0f);
    cell.bio.frame = labelFrame;
    cell.bio.text = [tweet objectForKey:@"Bio"];
    cell.bio.numberOfLines = 0;
    [cell.bio sizeToFit];
    cell.userID = [tweet objectForKey:@"id"];
    cell.userName.text = [tweet objectForKey:@"userName"];
    NSString *picURL = [tweet objectForKey: @"profilePic"];
    [cell.profilePic setImageWithURL:[NSURL URLWithString:picURL]];
    
    
    
    //set the state and image of the cell
    NSString *relationship = [tweet objectForKey:@"is_friend"];
    NSLog(@"Cell for row at index path has been called again, the value for relationship is %@", relationship);
    if ([relationship isEqualToString:@"YES"]) 
    {
        NSLog(@"You have assigned the value to 1");
        cell.requestSent = 1;
        UIImage *btnImage = [UIImage imageNamed:@"friends.png"];
        [cell.requestButton setImage:btnImage forState:UIControlStateNormal];
        
    }
    if ([relationship isEqualToString:@"NO"]) 
    {
        NSLog(@"You have assigned the value to 0");
        cell.requestSent = 0;
        UIImage *btnImage = [UIImage imageNamed:@"add.png"];
        [cell.requestButton setImage:btnImage forState:UIControlStateNormal];
        

    }
    
    //prevents highlighting of the cell
    [tableView setAllowsSelection:NO];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
    [TestFlight passCheckpoint:@"The user hit search on the searchBar"];
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

//- (IBAction)fbFriendSearch:(id)sender
//{
//    NSLog(@"You hit the faceBookFriendSearch method");
//    //initialze a tableView controller and send to screen
//    facebookFriendList * myFBTableView = [[facebookFriendList alloc] init];
//    
//    [self presentViewController:myFBTableView animated:YES completion:nil];
//    
//}




@end
