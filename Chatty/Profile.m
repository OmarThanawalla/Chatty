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

#import "FollowingUser.h"

#import "KeychainItemWrapper.h"
//import AFNetworking
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h> //This is for accessing layer properties in ProfilePicture to curve the image


@implementation Profile

@synthesize currentView;
@synthesize follows, follows2;
@synthesize firstName,lastName,userName,Bio,profilePicLink;

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
    [TestFlight passCheckpoint:@"Profile: User is viewing the Profile Tab"];

    //[self refresh];
      // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Set up Listener pattern
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyAction:) name:@"editProfile" object:nil];
    
    
    //Set up colors
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:48.0/256.0 green:49.0/256.0 blue:50.0/256.0 alpha:1.0];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"] forBarMetrics:UIBarMetricsDefault];
    //change tableview Image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;

    //set tableView seperator colors
    [self.tableView setSeparatorColor: [UIColor colorWithRed:224.0/256.0 green:224.0/256.0 blue:224.0/256.0 alpha:1.0]];
}

-(void)anyAction:(NSNotification *)anote
{
    NSLog(@"anyAction method fired. presumably from editProfile button being hit");
    [self performSegueWithIdentifier:@"editProfileModal" sender:self];
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
    [self refresh];
    
    //download user data
    [self downloadUserInfo];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) downloadUserInfo
{
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            nil];
    [[AFChattyAPIClient sharedClient] getPath:@"/updateUserInfo/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"Response: %@", responseObject);
         //rmr: responseObject is an array where each element is a diciontary
         //set the instance variables and call reload table
         NSDictionary *userJSON = responseObject;
         self.firstName = [userJSON objectForKey:@"first_name"];
         self.lastName = [userJSON objectForKey:@"last_name"];
         self.userName = [userJSON objectForKey:@"userName"];
         self.Bio = [userJSON objectForKey:@"Bio"];
         self.profilePicLink =[userJSON objectForKey:@"profilePic"];
         //NSLog(@"The URL for the profile pic is: %@", [userJSON objectForKey:@"profilePic"]);

         
         [self.tableView reloadData];
     }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error from postPath: %@",[error localizedDescription]);
         //else you cant connect, therefore push modalview login onto the stack
     }
     ];
    
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
    }
    //
    else
    {
        return [follows2 count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
   
    //profile segmented tab
    if (self.currentView == 0)
    {
                    //configure First Cell (profileCustomCell)
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
                        
                        cell.NameText.text = self.firstName;
                        cell.userName.text = self.userName;
                        
                        //sizeToFit the Bio Text
                        cell.BioText.text = self.Bio;
                        [cell.BioText sizeThatFits:CGSizeMake(40, 196)];
                        UILabel *myLabel = cell.BioText;
                        myLabel.font =[UIFont systemFontOfSize:17];
                        myLabel.lineBreakMode = NSLineBreakByWordWrapping; // "Wrap or clip the string only at word boundaries. This is the default wrapping option"
                        myLabel.numberOfLines = 0;
                        myLabel.tag = 1;
                        //Create Label Size
                        UIFont *cellFont = [UIFont systemFontOfSize:17];
                        CGSize constraintSize = CGSizeMake(175.0f, MAXFLOAT);           //This sets how wide we can go
                        CGSize labelSize = [self.Bio sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
                        CGRect temp = myLabel.frame;
                        temp.size = labelSize;
                        myLabel.frame = temp;
                        cell.BioText = myLabel;
                        
                        
                        [cell.ProfilePic setImageWithURL:[NSURL URLWithString:self.profilePicLink]];
                        NSLog(@"The URL for the profile pic is: %@", self.profilePicLink);
                        
                        cell.ProfilePic.layer.cornerRadius = 9.0;
                        cell.ProfilePic.layer.masksToBounds = YES;
                        cell.ProfilePic.layer.borderColor = [UIColor blackColor].CGColor;
                        cell.ProfilePic.layer.borderWidth = 0.0;
                        CGRect frame = cell.ProfilePic.frame;
                        frame.size.height = 60;
                        frame.size.width = 60;
                        cell.ProfilePic.frame = frame;
                        
                        //this prevents the cell from being hightlighted but still lets me hit the edit profile UIButton
                        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                        return cell;
                    }
                    else // configure 2-END cells (pending request cells)
                    {
                        
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
                        
                        //set UIImage with link to Profile Pic
                        
                        
                        cell.fullName.text = [user objectForKey:@"fullName"];
                        //reset the labelFrame because the cell could be dequed
                        CGRect labelFrame = CGRectMake(62.0f, 27.0f, 166.0f, 34.0f);
                        cell.bio.frame = labelFrame;
                        cell.bio.text = [user objectForKey:@"bio"];
                        cell.bio.numberOfLines = 0;
                        [cell.bio sizeToFit];
                        
                        cell.userName.text = [user objectForKey:@"userName"];
                        cell.userID = [user objectForKey:@"userID"];
                        NSString * ProfilePictureURL = [user objectForKey:@"profilePic"];
                        [cell.profilePic setImageWithURL:[NSURL URLWithString:ProfilePictureURL]];
                       
                        UIImage *btnImage = [UIImage imageNamed:@"pending.png"];
                        [cell.cnfmButton setImage:btnImage forState:UIControlStateNormal];
                        
                        
                        cell.profilePic.layer.cornerRadius = 9.0;
                        cell.profilePic.layer.masksToBounds = YES;
                        cell.profilePic.layer.borderColor = [UIColor blackColor].CGColor;
                        cell.profilePic.layer.borderWidth = 0.0;
                        CGRect frame = cell.profilePic.frame;
                        frame.size.height = 60;
                        frame.size.width = 60;
                        cell.profilePic.frame = frame;
                        
                        
                        //this prevents the cell from being hightlighted but still lets me hit the edit profile UIButton
                        [tableView setAllowsSelection:NO];
                        return cell;
                    }
        
    }
    //Following segmented Tab
    else{
        
        
        static NSString *CellIdentifier = @"followingUser";
        static BOOL nibsRegistered = NO;
        if(!nibsRegistered)
        {
            UINib *nib = [UINib nibWithNibName: @"FollowingUser" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        
        FollowingUser * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //reset the picture on the unfollow button because the cell could be dequeued
        UIImage *btnImage = [UIImage imageNamed:@"unfollow.png"];
        [cell.unfollowButton setImage:btnImage forState:UIControlStateNormal];
        
        NSDictionary *user = [follows2 objectAtIndex:indexPath.row];
        cell.fullName.text = [user objectForKey:@"fullName"];
        
        //set profile pic
        NSString *picURL = [user objectForKey: @"profilePic"];
        [cell.profilePic setImageWithURL:[NSURL URLWithString:picURL]];
        
        cell.profilePic.layer.cornerRadius = 9.0;
        cell.profilePic.layer.masksToBounds = YES;
        cell.profilePic.layer.borderColor = [UIColor blackColor].CGColor;
        cell.profilePic.layer.borderWidth = 0.0;
        CGRect frame = cell.profilePic.frame;
        frame.size.height = 50;
        frame.size.width = 50;
        cell.profilePic.frame = frame;
        
        //reset the labelFrame because the cell could be dequed
        CGRect labelFrame = CGRectMake(63.0f, 29.0f, 150.0f, 21.0f);
        cell.bio.frame = labelFrame;
        cell.bio.text = [user objectForKey:@"bio"];
        cell.bio.numberOfLines = 0;
        [cell.bio sizeToFit];
        
        cell.userName.text = [user objectForKey:@"userName"];
        cell.userID = [user objectForKey:@"userID"];
        //this prevents the cell from being hightlighted but still lets me hit the edit profile UIButton
        [tableView setAllowsSelection:NO];
        return cell;
    }
    


}



#pragma mark - Table view delegate


- (IBAction)toggleView:(id)sender {
    
    if([sender selectedSegmentIndex] == 1)
    {
        [TestFlight passCheckpoint:@"User is viewing people they are following"];
        self.currentView = 1;
        [self.tableView reloadData]; 
    } else {
        [TestFlight passCheckpoint:@"User is viewing their profile and pending requests"];
        self.currentView = 0;
        [self.tableView reloadData]; 
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(currentView == 0)
    {
        if (indexPath.section == 0)
        {
            return 120.0;
        }
        else
        {
        return 90.0;
        }
    }
    else
    {
        return 90.0;
    }
} 

-(IBAction) logout
{
    NSLog(@"The log out button was pushed");
    [TestFlight passCheckpoint:@"User hit the log out button"];

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

//drill down into the conversation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"logOut"])
    {
        NSLog(@"The log out segue was called");
         [FBSession.activeSession closeAndClearTokenInformation];
    }
}

-(IBAction)refresh
{
    [TestFlight passCheckpoint:@"User hit the refresh button in profile tab"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self downloadUserInfo];
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    if (currentView == 0)
    {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            nil];

    [[AFChattyAPIClient sharedClient] getPath:@"/follower/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          NSLog(@"Response: %@", responseObject);
                                          
                                          //set up follows array
                                          follows = responseObject;
                                          [self.tableView reloadData];
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                      }];

    }
    else // your in following segment
    {
        NSLog(@"youve pushed the refresh button while on following segment");
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                email, @"email",
                                password, @"password",
                                nil];
        
        [[AFChattyAPIClient sharedClient] getPath:@"/follow/" parameters:params
         //if login works, log a message to the console
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                              NSLog(@"Response: %@", responseObject);
                                              
                                              follows2 = responseObject;
                                              [self.tableView reloadData];
                                              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                              
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                              //else you cant connect, therefore push modalview login onto the stack
                                              [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                          }];
    }
}

@end
