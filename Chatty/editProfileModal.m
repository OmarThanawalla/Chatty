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
	// Do any additional setup after loading the view.
    NSLog(@"VIEWdidLoad set a profilePicture");
    [profilePic setImageWithURL:[NSURL URLWithString:@"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTCKiRD1oKcAUTAmli_0qraKJMdpXjd4Ws5fzlHmbUFglJs14ViIQ"] placeholderImage:[UIImage imageNamed:@"approved.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"You hit the save button");

    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"ChattyAppLoginData" accessGroup:nil];
    NSString * email = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    NSString * password = [keychain objectForKey:(__bridge id)kSecValueData];
    
    //NOTE: params will be part of NSMutableURLRequest
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            email, @"email",
                            password, @"password",
                            nil];

    //Grab Image
    UIImage *pic = profilePic.image;
    
    //Create NSData
    NSData *imageData = UIImageJPEGRepresentation(pic,0.5);
    
    //create the NSMUtableURLRequest
    NSMutableURLRequest *request = [[AFChattyAPIClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"/updateUserInfo/create" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"profilePicture" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
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
