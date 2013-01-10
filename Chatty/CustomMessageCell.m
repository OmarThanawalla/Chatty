//
//  CustomMessageCell.m
//  Chatty
//
//  Created by Gabriel Hernandez on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomMessageCell.h"
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
#import "KeychainItemWrapper.h"

@implementation CustomMessageCell
@synthesize SenderUser;
@synthesize MessageUser;
@synthesize Recipients;
@synthesize ProfilePicture;
@synthesize userName;
@synthesize cumulativeLikes;
@synthesize messageID;
@synthesize likeButton;

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

-(IBAction)likeAction
{
    NSLog(@"Like action depressed");
    NSLog(@"Also my messageId value is: %@", self.messageID);
    NSString * myID = self.messageID;
    
    //connect to the API
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    //NSLog(@"The value of conversationID is %i", conversationID);
    
     
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            myID, @"messageID",
                            nil];
    
    [[AFChattyAPIClient sharedClient] postPath:@"/does_like/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //self.messages = responseObject;
                                          NSLog(@"This is the response I recieved in the message view: %@", responseObject);
                                          //tell the parent tableview controller to refresh
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"likeButtonDepressed" object:nil userInfo:nil];
             
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
    
   //Change the text
    
    [likeButton setTitle:@"Doe" forState:UIControlStateNormal];
    //and disable the action of the button
    self.likeButton.userInteractionEnabled = NO;
}

-(void) isLike: (NSNumber *) myNumber
{
    if([myNumber intValue] == 1)
    {
        //Change the text
        [likeButton setTitle:@"Doe" forState:UIControlStateNormal];
        //and disable the action of the button
        self.likeButton.userInteractionEnabled = NO;

    }
}

@end
