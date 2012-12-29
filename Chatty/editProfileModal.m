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
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //start downloading the data
     [self downloadUserInfo];
}

-(void) downloadUserInfo
{   
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
                                              [self performSegueWithIdentifier:@"loggedIn" sender:self];
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
    
    // assign data to labels
    firstName.text = firstNameData;
    lastName.text = lastNameData;
    Bio.text = BioData;
    
}



-(IBAction)editPicture
{
    NSLog(@"You hit the editPicture button");
    //initialize imagePicker, imagePicker is a navigationController, which is a viewController as well
    imagePicker = [[UIImagePickerController alloc]init];
    
    //set the delegate
    imagePicker.delegate = self;
    
    //set the sourceType to camera or photoLibrary
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //present imagePicker as modalView
    [self presentModalViewController:imagePicker animated:YES];
    
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //image property is a UIImage
    NSLog(@"imagePicker did select image");
    profilePic.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"imagePicker did NOT select an image");
    [self dismissModalViewControllerAnimated:YES];
}

//Send the profilePic.image (UIImage) to the server

-(IBAction)save
{
    //Grab the fields 
    NSString *theFirst = self.firstName.text;
    NSString *theLast = self.lastName.text;
    NSString * theBio = self.Bio.text;
    
    
    
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
    NSLog(@"You hit the cancel button");
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
