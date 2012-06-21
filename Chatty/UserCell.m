//
//  UserCell.m
//  Chatty
//
//  Created by Omar Thanawalla on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserCell.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"
#import "AFChattyAPIClient.h"


@implementation UserCell
@synthesize profilePic;
@synthesize userName, bio;
@synthesize userID;

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

-(IBAction)follow
{
    
    /* GET THE PROFILE TAB DONE BEFORE YOU WRITE THE NETWORKNG CODE BECAUSE THE RELATIONSHIPS ARE SO CLOSELY LINKED */
    
    
    
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
//    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
//    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
//    
//    
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            email, @"email", 
//                            password, @"password",
//                            self.userID, @"targetFollow",
//                            nil];
//    
//    [[AFChattyAPIClient sharedClient] getPath:@"/follow/" parameters:params 
//     //if login works, log a message to the console
//                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                          //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                                          NSLog(@"Response: %@", responseObject);
//                                          
//                                          
//                                      } 
//                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
//                                          //else you cant connect, therefore push modalview login onto the stack
//                                      }];
}

@end
