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

@interface facebookFriendList ()

@end

@implementation facebookFriendList

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = @"Test";
    return cell;
}

#pragma mark - Table view delegate

- (void)openSession //2
{
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
                                          
                                          
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
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
    return [FBSession.activeSession handleOpenURL:url];
}


- (IBAction)dismiss:(id)sender
{
    NSLog(@"dimiss the view");
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
