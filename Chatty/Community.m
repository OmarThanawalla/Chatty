//
//  top60.m
//  Chatty
//
//  Created by Omar Thanawalla on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Community.h"
#import "Conversation.h"
#import "Login.h"
#import "AllCell.h"
#import "CustomMessageCell.h"
//import AFNetworking
#import "AFNetworking.h"


@implementation Community

@synthesize people;
@synthesize conversations;
@synthesize currentView;
@synthesize results;

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
    //
//    people = [[NSMutableArray alloc] initWithObjects:@"Ashimi, Jeddy, Nazish", @"Saleem, Shahneel, Omar", @"Danish, Miranda, Camille",@"Diviya, Saumiya, Ashimi", @"Kassam, Shanil, Shiraz, Kiran, Surge, Salim, Arman", nil];
//    conversations = [[NSMutableArray alloc] initWithObjects:@"Nazish: Dude I'm going to India", @"Omar: What did drake say when he was sitting on a mexican?", @"Danish: I look good", @"Diviya: I baked you a cupcake guys :)", @"Kassam: Our revenues are through the roof", nil];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    push in login on top of this view
        [self performSegueWithIdentifier:@"loggedIn" sender:self];
    //Testing AFNetworking for the first time
    
    
//    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/login/login"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    AFJSONRequestOperation *operation;
//    
//    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request 
//                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
//                 {//this is a block. In the block we can use the variables: request, response and JSON, to do things like log the contents of JSON or populate an NSArray or update the data source of aUITable view
//                     NSLog(@"The value of JSON is the following: %@", JSON);
//                     //results = [JSON objectForKey:@"results"];
//                     [self.tableView reloadData];
//                     //NSLog(@"Name: %@ %@ ",[JSON valueForKeyPath:@"first_name"],[JSON valueForKeyPath:@"last_name"]);
//                 } 
//                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
//                 {
//                     NSLog(@"Recieved an error, %d", response.statusCode);
//                     NSLog(@"The error was: %@", error);
//                 }
//                 ]; //closes AFJSONRequestOperationCall method
//    
//    
//    [operation start];
    
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
    return 1; //self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCellIdentifier";
    
    if(currentView == 0){
        static BOOL nibsRegistered = NO;
        if(!nibsRegistered)
        {
            UINib *nib = [UINib nibWithNibName: @"CustomMessageCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
            nibsRegistered = YES;
        }
        
        CustomMessageCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        cell.SenderUser.text = @"Dr. Mitra";
//        cell.Recipients.text = @"Gabe, Omar, Dr. Mitra";
//        cell.MessageUser.text = @"Extra Credit to anyone if you're interested";
        //NSDictionary *tweet = [self.results objectAtIndex:indexPath.row];
        //cell.SenderUser.text = [tweet objectForKey:@"from_user"];
        //cell.MessageUser.text = [tweet objectForKey:@"text"];
        return cell;
    }
        
    else { 
        AllCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[AllCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
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
    
    
    
    [self performSegueWithIdentifier:@"ShowCommunityConversation" sender:self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowCommunityConversation"]) {
        Conversation *myTop60 = [segue destinationViewController];
        if(currentView == 0)
        {
        myTop60.state = 0;
        }
        if(currentView == 1)
        {
            myTop60.state = 2;
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 85;
}


- (IBAction)toggleView:(UISegmentedControl *)sender {
    if([sender selectedSegmentIndex] == 1)
    {
        //hang on
        self.currentView = 1;
        [self.tableView reloadData]; 
        NSLog(@"current view set to 1");
    } else {
        self.currentView = 0;
        [self.tableView reloadData]; 
        NSLog(@"current view set to 0");
    }

}
@end
