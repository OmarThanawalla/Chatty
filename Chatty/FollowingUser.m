//
//  FollowingUser.m
//  Chatty
//
//  Created by Omar Thanawalla on 8/21/12.
//
//

#import "FollowingUser.h"
#import "KeychainItemWrapper.h"
//import AFNetworking
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"

@implementation FollowingUser
@synthesize fullName, bio, profilePic, userID, userName, unfollowButton;

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

-(IBAction) unfollow
{
    NSLog(@"You pushed the unfollow button");
    NSLog(@"the user id is %@", userID);
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            userID, @"followerID",
                            nil];
    
    [[AFChattyAPIClient sharedClient] getPath:@"/follow/1/" parameters:params
     //if login works, log a message to the console
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                           NSLog(@"Response: %@", responseObject);
//                                           UIImage *btnImage = [UIImage imageNamed:@"green-checkmark.png"];
//                                           [cnfmButton setImage:btnImage forState:UIControlStateNormal];
                                           
                                           
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                           //else you cant connect, therefore push modalview login onto the stack
                                       }];
}

@end
