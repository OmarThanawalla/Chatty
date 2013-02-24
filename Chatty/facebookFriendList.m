//
//  facebookFriendList.m
//  Chatty
//
//  Created by Omar Thanawalla on 1/29/13.
//
//

#import "facebookFriendList.h"
#import <FacebookSDK/FacebookSDK.h>
#import "KeychainItemWrapper.h"
#import "AFChattyAPIClient.h"
#import "UserCell.h"
#import <QuartzCore/QuartzCore.h> //This is for accessing layer properties in ProfilePicture to curve the image
#import "AFNetworking.h"

@interface facebookFriendList ()

@end

@implementation facebookFriendList
@synthesize listOfUsers;

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
    [TestFlight passCheckpoint:@"facebookFriendList class has been presented to the user"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //set up colors
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:48.0/256.0 green:49.0/256.0 blue:50.0/256.0 alpha:1.0];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar.png"] forBarMetrics:UIBarMetricsDefault];
    //change tableview Image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    //Begin call to facebook
    [self openSession]; //1
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell.requestButton.tintColor = [UIColor colorWithRed: 255.0/256.0 green:255.0/256.0 blue:255.0/256.0 alpha:0.1];
    cell.requestButton.layer.borderWidth = 0.0;
    CGRect requestBtnFrame = cell.requestButton.frame;
    requestBtnFrame.origin.x = 250;
    cell.requestButton.frame = requestBtnFrame;
    
    
    // Configure the cell...
    //configure cell here
    NSDictionary * tweet = [listOfUsers objectAtIndex:indexPath.row];
    NSString *firstName = [tweet objectForKey:@"firstName"];
    NSString *lastName = [tweet objectForKey:@"lastName"];
    cell.fullName.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    //cell.fullName.font = [UIFont systemFontOfSize:13];

    
    //resize the bio label since you are dequeing some of them
//    CGRect labelFrame = CGRectMake(68.0f, 21.0f, 211.0f, 41.0f);
//    cell.bio.frame = labelFrame;
    cell.bio.text = @" ";//[tweet objectForKey:@"Bio"];
//    cell.bio.numberOfLines = 0;
//    [cell.bio sizeToFit];
    cell.userID = [tweet objectForKey:@"id"];
    cell.userName.text = [tweet objectForKey:@"userName"];
    cell.userName.font = [UIFont systemFontOfSize:13];
    CGRect temp2 = cell.userName.frame;
    temp2.origin.y = 28 ;
    cell.userName.frame = temp2;
    
    //Setting Profile Picture
    NSString *picURL = [tweet objectForKey: @"profilePic"];
    [cell.profilePic setImageWithURL:[NSURL URLWithString:picURL]];
    cell.profilePic.layer.cornerRadius = 9.0;
    cell.profilePic.layer.masksToBounds = YES;
    cell.profilePic.layer.borderColor = [UIColor blackColor].CGColor;
    cell.profilePic.layer.borderWidth = 0.0;
    CGRect frame = cell.profilePic.frame;
    frame.size.height = 50;
    frame.size.width = 50;
    cell.profilePic.frame = frame;
    
    
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
    return 65;
}

#pragma mark - Table view delegate

- (void)openSession //2
{
    [TestFlight passCheckpoint:@"facebookFriendList: Attemping to open session"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //[FBSettings setLoggingBehavior:[NSSet setWithObjects: FBLoggingBehaviorFBRequests, nil]];
    //get permissions
    NSArray *permissions = [[NSArray alloc] initWithObjects:
//                            @"user_location",
//                            @"user_birthday",
                            @"email",
                            //@"user_about_me",
                            //@"updated_time",
                            //@"access_token",
                            nil];
    
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         //call this method in the code block when openActiveSession... method is successful
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)sessionStateChanged:(FBSession *)session //3
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            //if the top view controller is the login viewcontroller dismiss that view controller
            NSLog(@"I think you are logged in");
            [TestFlight passCheckpoint:@"facebookFriendList Class: Successfully logged into facebook"];
            //method intends to ask facebook for a list of friends
            [self callFriendList];
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            //[self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            //[self showLoginView];   //shows login view
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void) callFriendList //4
{
    [TestFlight passCheckpoint:@"facebookFriendList: CallFriendList method called"];
    NSLog(@"You made it to the callFriendList method");
    
    
    NSString * theToken = FBSession.activeSession.accessToken;
    NSLog(@"the access token is: %@", theToken );
    
    //send rails the access token
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    //set up params
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            theToken, @"fbToken",
                            nil];
    
    //make the call
    [[AFChattyAPIClient sharedClient] getPath:@"/friend_list_fb/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"This is the response I recieved: %@", responseObject);
                                          //set the list of users here
                                          self.listOfUsers = responseObject;
                                          //refresh the table
                                          [self.tableView reloadData];
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                          [TestFlight passCheckpoint:@"facebookFriendList: Successfully connected to rails API to retrieve list of user"];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                          [TestFlight passCheckpoint:@"facebookFriendList: Did not successfully connect to rails API"];
                                      }];
    
    //IF YOU DESIRE TO CALL A LIST OF FB FRIENDS FROM THE IPHONE APP ITSELF
    //    [FBRequestConnection startWithGraphPath:@"me/friends?fields=installed" completionHandler:^(FBRequestConnection *connection, id data, NSError *error) {
    //        if(error) {
    //
    //            return;
    //        }
    //        NSArray* friends = (NSArray*) data[@"data"];
    //        NSLog(@"You have %d friends", [friends count]);
    //        for(int i = 0; i < [friends count]; i++)
    //        {
    //            NSDictionary * person = (NSDictionary*) [friends objectAtIndex:i];
    //            BOOL  installed = (BOOL) person[@"installed"];
    //            // NSLog(@"%c",installed);
    //
    //        }
    
    
}

- (BOOL)application:(UIApplication *)application //5 i think you have to leave this here? maybe ill just set up another copy elsewhere too
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    [TestFlight passCheckpoint:@"facebookFriendList: User just came back from facebook fast app switching"];
    return [FBSession.activeSession handleOpenURL:url];
}


- (IBAction)dismiss:(id)sender
{
    NSLog(@"dimiss the view");
    [TestFlight passCheckpoint:@"facebookFriendList: User dismissed the view"];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)followAll:(id)sender
{
    NSLog(@"followAll has been called");
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload {
    
    [super viewDidUnload];
}
@end
