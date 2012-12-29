//
//  autoCompleteEngine.m
//  Chatty
//
//  Created by Omar Thanawalla on 12/16/12.
//
//

#import "autoCompleteEngine.h"
#import "autoCompleteCell.h"

//import AFNetworking
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
#import "KeychainItemWrapper.h"

@interface autoCompleteEngine ()

@end

@implementation autoCompleteEngine
@synthesize myUsers, currentQuery;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    NSLog(@"You have instantiated an object from class autoCompleteEngine");
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [myUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static BOOL nibsRegistered = NO;
    if(!nibsRegistered)
    {
        UINib *nib = [UINib nibWithNibName: @"autoComplete" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
        //nibsRegistered = YES;
    }

    autoCompleteCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *user = [self.myUsers objectAtIndex:indexPath.row];
    
    //fill the cells with first, last, and username
    cell.userName.text = [user objectForKey:@"userName"];
    
    //fullName
    NSString *firstName = [user objectForKey:@"firstName"];
    NSString *firstNameWithSpace = [firstName stringByAppendingString:@" "];
    NSString *lastName = [user objectForKey:@"lastName"];
    NSString * fullName = [firstNameWithSpace stringByAppendingString:lastName];
    cell.fullName.text = fullName;
    //set profile picture
    NSString *picURL = [user objectForKey: @"profilePic"];
    //NSLog(@"The url for the pic is: %@", picURL);
    [cell.profilePicture setImageWithURL:[NSURL URLWithString:picURL]];
    
    return cell;
}


-(void) searchKickOff: (NSString *) query
{
    
    self.currentQuery = query;
    NSLog(@"The value of query is: %@", self.currentQuery);
    //call search method
    [self refresh];
    
}
//with the query go get 
-(void) refresh
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email", 
                            password, @"password",
                            self.currentQuery, @"query",
                            nil];
    
    [[AFChattyAPIClient sharedClient] getPath:@"/query/" parameters:params 
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          NSLog(@"Response: %@", responseObject);
                                          //rmr: responseObject is an array where each element is a diciontary
                                          myUsers = responseObject;
                                          [self.tableView reloadData];
                                          
                                          
                                      } 
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                          //[self performSegueWithIdentifier:@"loggedIn" sender:self];
                                      }];

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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    //Grab the userName from the cell
    autoCompleteCell *cell = (autoCompleteCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSString *userName = cell.userName.text;
    
    //package the userName in a dictionary
    NSDictionary *aDict = @{@"userName" : userName};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userNameSelected" object:nil userInfo:aDict];
}

@end
