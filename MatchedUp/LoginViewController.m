//
//  LoginViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/6/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Constants.h"
#import <PFFile.h>
#import <PFQuery.h>

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//	FBLoginView *loginView = [[FBLoginView alloc] init];
//	loginView.center = self.view.center;
//	[self.view addSubview:loginView];

	self.activityIndicator.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
	{
		[self updateUserInformation];
		[self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender
{
	self.activityIndicator.hidden = NO;
	[self.activityIndicator startAnimating];

	NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];

	[PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
		self.activityIndicator.hidden = YES;
		[self.activityIndicator stopAnimating];
		if (!user)
		{
			if (!error)
			{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"The Facebook login was cancelled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alertView show];
			}
			else
			{
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alertView show];
			}
		}
		else
		{
			[self updateUserInformation];
			[self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
		}
	}];
}

#pragma mark - Helper Methods

-(void)updateUserInformation
{
	FBRequest *request = [FBRequest requestForMe];
	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (!error)
		{
			NSDictionary *userDictionary = (NSDictionary *)result;


			// create URL
			NSString *facebookID = userDictionary[@"id"];
			NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",facebookID]];


			NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];

			// Get values from dictionary
			if (userDictionary[@"name"])
			{
				userProfile[kSMTUserProfileNameKey] = userDictionary[@"name"];
			}
			if (userDictionary[@"first_name"])
			{
				userProfile[kSMTUserProfileFirstNameKey] = userDictionary[@"first_name"];
			}
			if (userDictionary[@"location"][@"name"])
			{
				userProfile[kSMTUserProfileLocationKey] = userDictionary[@"location"][@"name"];
			}
			if (userDictionary[@"gender"])
			{
				userProfile[kSMTUserProfileGenderKey] = userDictionary[@"gender"];
			}
			if (userDictionary[@"birthday"])
			{
				userProfile[kSMTUserProfileBirthdayKey] = userDictionary[@"birthday"];
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateStyle:NSDateFormatterShortStyle];
				NSDate *birthday = [formatter dateFromString:userDictionary[@"birthday"]];
				NSTimeInterval seconds = [birthday timeIntervalSinceNow];
				int age = (seconds * -1) / 31536000;
				userProfile[kSMTUserProfileAgeKey] = @(age);
			}
			if (userDictionary[@"interested_in"])
			{
				userProfile[kSMTUserProfileInterestedInKey] = userDictionary[@"interested_in"];
			}
			if (userDictionary[@"relationship_status"])
			{
				userProfile[kSMTUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
			}
			if ([pictureURL absoluteString])
			{
				userProfile[kSMTUserProfilePictureURLKey] = [pictureURL absoluteString];
			}


			[[PFUser currentUser] setObject:userProfile forKey:kSMTUserProfileKey];
			[[PFUser currentUser] saveInBackground];

			[self requestImage];
		}
		else
		{
			NSLog(@"Error in FB me request: %@",error);
		}
	}];
}

-(void)uploadPFFileToParse:(UIImage *)image
{
	NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
	if (!imageData)
	{
		NSLog(@"Image Data was not found");
		return;
	}

	PFFile *photoFile = [PFFile fileWithData:imageData];
	[photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (succeeded)
		{
			PFObject *photo = [PFObject objectWithClassName:kSMTPhotoClassKey];
			[photo setObject:[PFUser currentUser] forKey:kSMTPhotoUserKey];
			[photo setObject:photoFile forKey:kSMTPhotoPictureKey];
			[photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				NSLog(@"Photo saved successfully");
			}];
		}
		else
		{
			NSLog(@"Error saving photo: %@",error);
		}
	}];
}

-(void)requestImage
{
	PFQuery *query = [PFQuery queryWithClassName:kSMTPhotoClassKey];
	[query whereKey:kSMTPhotoUserKey equalTo:[PFUser currentUser]];

	[query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
		if(number == 0)
		{
			PFUser *user = [PFUser currentUser];
			self.imageData = [[NSMutableData alloc] init];

			NSURL *profilePictureURL = [NSURL URLWithString:user[kSMTUserProfileKey][kSMTUserProfilePictureURLKey]];
			NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
			NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
			if (!urlRequest)
			{
				NSLog(@"Failed to download picture");
			}
		}
		else
		{

		}
	}];
}

#pragma mark - <NSURLConnectionDataDelegate>

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	UIImage *profileImage = [UIImage imageWithData:self.imageData];
	[self uploadPFFileToParse:profileImage];
}

@end
