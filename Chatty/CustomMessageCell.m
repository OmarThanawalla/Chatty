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
//#import <QuartzCore/QuartzCore.h>

@implementation CustomMessageCell
@synthesize SenderUser;
@synthesize MessageUser;
@synthesize Recipients;
@synthesize ProfilePicture;
@synthesize userName;
@synthesize cumulativeLikes;
@synthesize messageID;
@synthesize likeButton;
@synthesize stateOfCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        stateOfCell = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//This is called when the like button has been pressed
-(IBAction)likeAction
{
    [TestFlight passCheckpoint:@"User hit the like button on a customMessage cell"];
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
    
    //Alter the state of the cell
    if (stateOfCell == NO) {
        stateOfCell = YES;
    }
    else{//state of cell == YES
        stateOfCell = NO;
    }
    
    //MAKE THE CALLS TO RAILS
    
    //LIKE IT (CREATES A RECORD IN LIKES TABLE)
    if(stateOfCell == YES)
    {
    [[AFChattyAPIClient sharedClient] postPath:@"/does_like/" parameters:params
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //self.messages = responseObject;
                                          NSLog(@"This is the response I recieved in the message view: %@", responseObject);
                                          //tell the parent tableview controller to refresh
                                          //dont do the below code, too inefecient
                                          //[[NSNotificationCenter defaultCenter] postNotificationName:@"likeButtonDepressed" object:nil userInfo:nil];
             
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                      }];
    
   //Change the image
    [likeButton setImage:[UIImage imageNamed:@"likedMe.png"] forState:UIControlStateNormal];
   //increment the like counter
        NSString *value = self.cumulativeLikes.text;
        int likesInInt = [value intValue];
        likesInInt = likesInInt + 1;
        self.cumulativeLikes.text = [NSString stringWithFormat:@"%i", likesInInt];
    }
    //UNLIKE IT (DELETES A RECORD IN LIKES TABLE)
    else // stateOfCell == NO
    {
        NSLog(@"The stateOfCell is unliked");
        //send message to Rails to destory recrod that i like the message and to decrement the cumulativeLikes attribute of the message
        
        [[AFChattyAPIClient sharedClient] getPath:@"/does_like/" parameters:params
         //if login works, log a message to the console
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               //self.messages = responseObject;
                                               NSLog(@"This is the response I recieved in the message view: %@", responseObject);
                                               //tell the parent tableview controller to refresh
                                               //dont do the below code, too inefficeient
                                               //[[NSNotificationCenter defaultCenter] postNotificationName:@"likeButtonDepressed" object:nil userInfo:nil];
                                               
                                           }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                           }];
        
        
        //change the image of the cell
        [likeButton setImage:[UIImage imageNamed:@"likeMe.png"] forState:UIControlStateNormal];
        
        //increment the like counter
        NSString *value = self.cumulativeLikes.text;
        int likesInInt = [value intValue];
        likesInInt = likesInInt - 1 ;
        self.cumulativeLikes.text = [NSString stringWithFormat:@"%i", likesInInt];
        
    }
}

-(void) isLike: (NSNumber *) myNumber
{
    
    if([myNumber intValue] == 1)
    {
        //set the state of the cell
        stateOfCell = YES;
        //Set the Image of the Button to "LikedMe"
        [likeButton setImage:[UIImage imageNamed:@"likedMe.png"] forState:UIControlStateNormal];
        
        

    }
    else    //the user has not liked the cell
    {
        // set the state of the cell
        stateOfCell = NO;
        //Set the Image of the Button to "LikeMe"
        [likeButton setImage:[UIImage imageNamed:@"likeMe.png"] forState:UIControlStateNormal];
        
    }
}

@end
