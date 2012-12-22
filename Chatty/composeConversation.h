//
//  composeMessage.h
//  Chatty
//
//  Created by Omar Thanawalla on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class autoCompleteEngine;  //This allows this class to see autoComplete since import does not. hm maybe i should take that compilers elective
@interface composeConversation : UIViewController <UITextViewDelegate>

/*
@protocol composeMessageDelegate <NSObject>
@required
//something goes in here
-(void)set
@end
 */

@property (nonatomic, retain) IBOutlet UITextView *myTextView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *characterCount;

//This will hold our viewcontroller to display the autocompleted choices
@property (nonatomic, strong) autoCompleteEngine * autoCompleteObject;
@property (nonatomic, assign) BOOL viewOn;
@property (nonatomic, strong) NSMutableString *theWord; //this holds the word left of the cursor always

-(IBAction)cancelButton;
-(IBAction)sendButton;

//inserts the userName into the textbox
-(void)autoCompleteFinish;
@end
