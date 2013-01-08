//
//  Message.h
//  Chatty
//
//  Created by Omar Thanawalla on 1/7/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSNumber * conversationID;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * profilePic;
@property (nonatomic, retain) NSString * preAddressing; //i intended to use this to store all the users in a given conversation, but then i realized this was a stupid mistake

@end
