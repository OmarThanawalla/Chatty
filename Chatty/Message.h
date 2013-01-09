//
//  Message.h
//  Chatty
//
//  Created by Omar Thanawalla on 1/9/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSNumber * conversationID;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * likesCount;
@property (nonatomic, retain) NSString * messageContent;
@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSString * preAddressing;
@property (nonatomic, retain) NSString * profilePic;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSString * userName;

@end
