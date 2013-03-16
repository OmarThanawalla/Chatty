//
//  Registered3.m
//  Chatty
//
//  Created by Omar Thanawalla on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Registered3.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"
#import "AFChattyAPIClient.h"
#import <QuartzCore/QuartzCore.h> //This is for accessing layer properties in ProfilePicture to curve the image

@interface Registered3 ()

@end

@implementation Registered3
@synthesize userName, bio,firstName,lastName;
@synthesize email, password;
@synthesize notice;
@synthesize imagePicker;
@synthesize displayedProfilePic;
@synthesize profilePic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Registration: Step 2 of 2";
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_4.png"]];
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
	// Do any additional setup after loading the view.
    NSLog(@"Email and password: %@, %@",email, password);
}

-(void) viewWillDisappear:(BOOL)animated
{
    self.notice.text = @"";
}

- (void)viewDidUnload
{
    [self setDisplayedProfilePic:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(IBAction) register
{
    NSLog(@"You pushed the register button");
    //client side validation
    BOOL isUsernameEmpty = [userName.text isEqualToString:@""];
    BOOL isFirstnameEmpty = [firstName.text isEqualToString:@""];
    BOOL isLastnameEmpty = [lastName.text isEqualToString:@""];
    
    //if they are all not empty then go ahead and submit
    if (!isUsernameEmpty && !isFirstnameEmpty && !isLastnameEmpty)
    {
        //submit
        NSLog(@"the first three boxes have something in them");
        [self submit];
        
    }
    //submit params with AFNetworking code
    
}
-(void) submit
{
    //got the keychain ready
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];

    //lowercase the userName and email so we dont store it not lowercased
    self.userName.text = [self.userName.text lowercaseString];
    self.email = [self.email lowercaseString];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.email, @"email", 
                            self.password, @"password",
                            self.userName.text, @"userName",
                            self.firstName.text, @"firstName",
                            self.lastName.text, @"lastName",
                            self.bio.text, @"Bio",
                            nil];
    //
    
    [[AFChattyAPIClient sharedClient] postPath:@"/user/create" parameters:params 
     //if login works, log a message to the console
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"Response: %@", [responseObject class]);
                                          NSString *responseString = [responseObject objectAtIndex:0];
                                          if([responseString isEqualToString:@"YES"])
                                          {
                                              NSLog(@"Record saved");
                                              //save in key chain
                                              //dismiss modal view
                                              [keychain setObject:self.email forKey:(__bridge id) kSecAttrAccount];
                                              [keychain setObject:self.password forKey:(__bridge id)kSecValueData];
                                              [TestFlight passCheckpoint:@"Successfully created a new account"];
                                              [self dismissModalViewControllerAnimated:YES];
                                              //if user registered, then update profile picture
                                              [self uploadProfilePicture];
                                              //update deviceToken in rails --call method
                                              [self updateDeviceToken];
                                          }
                                          if([responseString isEqualToString:@"NO"])
                                           {
                                             NSLog(@"Record not saved");
                                             //say error
                                             
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                                             message:@"The Username or Email has already been taken"
                                                                                            delegate:nil
                                                                                   cancelButtonTitle:@"OK"
                                                                                   otherButtonTitles:nil];
                                             [alert show];
                                             [TestFlight passCheckpoint:@"Did not successfully create a new account"];
                                        }
                                          
                                          
                                          
                                      } 
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                          //else you cant connect, therefore push modalview login onto the stack
                                      }];
    
    //

    
}

//if successful registration then upload profile picture
-(void) uploadProfilePicture
{
    NSLog(@"uploadProfilePicture method is called");
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email2 = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password2 = [keychain objectForKey:(__bridge id)kSecValueData];
    
    //NOTE: params will be part of NSMutableURLRequest
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email2, @"email",
                            password2, @"password",
                            nil];
    //Grab Image
    UIImage *pic = self.profilePic.image;
    //assert(pic1 != NULL);
    
    //UIImage *pic = [UIImage imageNamed:@"friends.png"];
    
    //Create NSData // reduce image quality to speed upload, decrease storage size on amazon, and speed download
    NSData *imageData = UIImageJPEGRepresentation(pic,0.1);
    
    //create the NSMUtableURLRequest
    NSMutableURLRequest *request = [[AFChattyAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"/updateUserInfo/updatePicture" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"profilePicture" fileName:@"avatar.png" mimeType:@"image/png"];
    }];
    
    //create the AFHTTPRequestOperation object
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    //start operation
    [operation start];

}

- (IBAction)addPicture:(id)sender
{
    NSLog(@"did hit addPicture button");
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    [self presentModalViewController:imagePicker animated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePicker did select image");
    //profilePic shall be unadulterated copy of profile pic
    UIImage *myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:myImage];
    self.profilePic = backgroundImageView;
    
//    self.displayedProfilePic.image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    self.displayedProfilePic.layer.cornerRadius = 9.0;
//    self.displayedProfilePic.layer.masksToBounds = YES;
//    self.displayedProfilePic.layer.borderColor = [UIColor blackColor].CGColor;
//    self.displayedProfilePic.layer.borderWidth = 0.0;
    
    [self dismissModalViewControllerAnimated:YES];
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [TestFlight passCheckpoint:@"register3 Class: User cancled out of selecting a picture"];
    NSLog(@"imagePicker did NOT select an image");
    [self dismissModalViewControllerAnimated:YES];
}

-(void) updateDeviceToken
{
    [TestFlight passCheckpoint:@"Login: calling updateDeviceToken"];
    //retrieve deviceToken
    NSUserDefaults * standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *SavedDeviceToken = [standardUserDefaults objectForKey:@"keyToLookupString"];
    
    //send device token to rails
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * emailLog = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * passwordLog = [keychain objectForKey:(__bridge id)kSecValueData];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            emailLog, @"email",
                            passwordLog, @"password",
                            SavedDeviceToken, @"token",
                            nil];
    [[AFChattyAPIClient sharedClient] postPath:@"/update_token/" parameters:params
     //if login works, log a message to the console
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                           NSLog(@"Did update token: %@", responseObject);
                                           [TestFlight passCheckpoint:@"AppDelegate: Successfuly sent rails deviceToken"];
                                           //rmr: responseObject is an array where each element is a diciontary
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                           [TestFlight passCheckpoint:@"AppDelegate: Failed in sending rails deviceToken"];
                                       }];
    
}

@end
