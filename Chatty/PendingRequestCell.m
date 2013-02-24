//
//  PendingRequestCell.m
//  Chatty
//
//  Created by Omar Thanawalla on 8/20/12.
//
//

#import "PendingRequestCell.h"
#import "KeychainItemWrapper.h"
//import AFNetworking
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
@implementation PendingRequestCell
@synthesize fullName, bio, profilePic, userName, userID, cnfmButton;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction) confirmButton
{
    [TestFlight passCheckpoint:@"User confirmed the allowing of someone to follow him"];
    NSLog(@"You pushed the confirmButton on the PendingRequestCell");
    //send userID of the person we want to confirm
    NSLog(@"The user ID of the cell is %@",userID);
    
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            userID, @"followerID",
                            nil];
    
    [[AFChattyAPIClient sharedClient] postPath:@"/follower/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                          NSLog(@"Response: %@", responseObject);
                                          UIImage *btnImage = [UIImage imageNamed:@"friends.png"];
                                          [cnfmButton setImage:btnImage forState:UIControlStateNormal];
                                          
                                          
                                          
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                      }];

    
    
}
@end
