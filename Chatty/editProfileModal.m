//
//  editProfileModal.m
//  Chatty
//
//  Created by Omar Thanawalla on 12/22/12.
//
//

#import "editProfileModal.h"
//import AFNetworking
#import "AFNetworking.h"
#import "AFChattyAPIClient.h"
#import "KeychainItemWrapper.h"
#import <QuartzCore/QuartzCore.h> //This is for accessing layer properties in ProfilePicture to curve the image

@interface editProfileModal ()

@end

@implementation editProfileModal
@synthesize firstName, lastName,Bio;
@synthesize profilePic;
@synthesize imagePicker;
@synthesize  resultsDict;

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
    [TestFlight passCheckpoint:@"User is viewing editing their profile"];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg_4.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:68.0/256.0 green:71.0/256.0 blue:72.0/256.0 alpha:1.0];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_4.png"] ];
    [self.Bio setClipsToBounds:YES];
    self.Bio.layer.cornerRadius = 10.0f;
}
-(void)viewWillAppear:(BOOL)animated
{
    //start downloading the data
     [self downloadUserInfo];
}

-(void) downloadUserInfo
{
    NSLog(@"You called the downloadUserInfo method");
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            nil];
        [[AFChattyAPIClient sharedClient] getPath:@"/updateUserInfo/" parameters:params
         //if login works, log a message to the console
                                          success:^(AFHTTPRequestOperation *operation, id responseObject)
                                          {
                                              //NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                              NSLog(@"Response: %@", responseObject);                                           
                                              resultsDict = responseObject;
                                              [self fillUserInfo];
                                              //rmr: responseObject is an array where each element is a diciontary
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                          {
                                              NSLog(@"Error from postPath: %@",[error localizedDescription]);
                                              //else you cant connect, therefore push modalview login onto the stack
                                              
                                          }
         ];
        
       }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fillUserInfo
{
    //pull JSON Data
    NSString *firstNameData = [resultsDict objectForKey:@"first_name"];
    NSString *lastNameData = [resultsDict objectForKey:@"last_name"];
    NSString *BioData = [resultsDict objectForKey:@"Bio"];
    //NSString *pic = [resultsDict objectForKey:@"profilePic"];
    
    // assign data to labels
    firstName.text = firstNameData;
    lastName.text = lastNameData;
    Bio.text = BioData;
    //[self.profilePic setImageWithURL:[NSURL URLWithString:pic]];
    
    //curve the profile pic
    self.profilePic.layer.cornerRadius = 9.0;
    self.profilePic.layer.masksToBounds = YES;
    self.profilePic.layer.borderColor = [UIColor blackColor].CGColor;
    self.profilePic.layer.borderWidth = 0.0;
    CGRect frame = self.profilePic.frame;
    frame.size.height = 50;
    frame.size.width = 50;
    self.profilePic.frame = frame;
}



-(IBAction)editPicture
{
    NSLog(@"You hit the editPicture button");
    [TestFlight passCheckpoint:@"User hit the edit picture button"];
    //initialize imagePicker, imagePicker is a navigationController, which is a viewController as well
    imagePicker = [[UIImagePickerController alloc]init];
    
    //set the delegate
    imagePicker.delegate = self;
    
    //set the sourceType to camera or photoLibrary
    //if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    //{
    //    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //}
    //else
    //{
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    //present imagePicker as modalView
    [self presentModalViewController:imagePicker animated:YES];
    
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [TestFlight passCheckpoint:@"editProfileModal Class: User selected a profile picture with which to save"];
    //image property is a UIImage
    NSLog(@"imagePicker did select image");
    profilePic.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [TestFlight passCheckpoint:@"editProfileModal Class: User cancled out of selecting a picture"];
    NSLog(@"imagePicker did NOT select an image");
    [self dismissModalViewControllerAnimated:YES];
}

//Send the profilePic.image (UIImage) to the server

-(IBAction)save
{
    [TestFlight passCheckpoint:@"editProfileModal: User hit the save button, save changes"];
    //Grab the fields 
    NSString *theFirst = self.firstName.text;
    NSString *theLast = self.lastName.text;
    NSString * theBio = self.Bio.text;
    
    NSLog(@"save: %@", theFirst);
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    //NOTE: params will be part of NSMutableURLRequest
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            theFirst, @"first_name",
                            theLast, @"last_name",
                            theBio, @"Bio",
                            nil];

    //Grab Image
    UIImage *pic = profilePic.image;
    
    //Create NSData // reduce image quality to speed upload, decrease storage size on amazon, and speed download
    NSData *imageData = UIImageJPEGRepresentation(pic,0.1);
    
    //create the NSMUtableURLRequest
    NSMutableURLRequest *request = [[AFChattyAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"/updateUserInfo/create" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"profilePicture" fileName:@"avatar.png" mimeType:@"image/png"];
    }];
    
    //create the AFHTTPRequestOperation object
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    //start operation
    [operation start];
    
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}
 

-(IBAction)cancel
{
    [TestFlight passCheckpoint:@"editprofileModal Class: User cancled out of saving changes to profile"];
    NSLog(@"You hit the cancel button");
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
