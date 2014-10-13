//
//  HomeViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/9/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "TestUser.h"
#import "MatchViewController.h"
#import "ProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <PFQuery.h>
#import <PFFile.h>

@interface HomeViewController () <MatchViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//	[TestUser saveTestUserToParse];

	// We don't want users to be able to push the buttons before the pictures download
	self.likeButton.enabled = NO;
	self.dislikeButton.enabled = NO;
	self.infoButton.enabled = NO;

	self.currentPhotoIndex = 0;

	// Query to get the other users
	PFQuery *query = [PFQuery queryWithClassName:kSMTPhotoClassKey];
	[query whereKey:kSMTPhotoUserKey notEqualTo:[PFUser currentUser]];
	[query includeKey:kSMTPhotoUserKey];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			self.photos = objects;
			[self queryForCurrentPhotoIndex];
			[self updateView];
		}
		else
		{
			NSLog(@"Error getting users: %@",error);
		}
	}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

	if ([segue.identifier isEqualToString:@"homeToProfileSegue"] )
	{
		ProfileViewController *profileVC = segue.destinationViewController;
		profileVC.photo = self.photo;
	}
	else if ([segue.identifier isEqualToString:@"homeToMatchSegue"])
	{
		MatchViewController *matchVC = segue.destinationViewController;
		matchVC.matchedUserImage = self.photoImageView.image;
		matchVC.delegate = self;
	}
}

#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender
{

}

- (IBAction)likeButtonPressed:(UIButton *)sender
{
	[self checkLikeStatus:YES];
}

- (IBAction)dislikebuttonPressed:(UIButton *)sender
{
	[self checkLikeStatus:NO];
}

- (IBAction)infoButtonPressed:(UIButton *)sender
{
	[self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}

#pragma mark - Helper methods

-(void)queryForCurrentPhotoIndex
{
	if ([self.photos count] > 0)
	{
		self.photo = self.photos[self.currentPhotoIndex];
		PFFile *file = self.photo[kSMTPhotoPictureKey];
		[file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
			if (!error)
			{
				UIImage *image = [UIImage imageWithData:data];
				self.photoImageView.image = image;
			}
			else
			{
				NSLog(@"Error saving photos: %@",error);
			}
		}];

		PFQuery *queryForLike = [PFQuery queryWithClassName:kSMTActivityClassKey];
		[queryForLike whereKey:kSMTActivityTypeKey equalTo:kSMTActivityTypeLikeKey];
		[queryForLike whereKey:kSMTActivityPhotoKey equalTo:self.photo];
		[queryForLike whereKey:kSMTActivityFromUserKey equalTo:[PFUser currentUser]];

		PFQuery *queryForDislike = [PFQuery queryWithClassName:kSMTActivityClassKey];
		[queryForDislike whereKey:kSMTActivityTypeKey equalTo:kSMTActivityTypeDislikeKey];
		[queryForDislike whereKey:kSMTActivityPhotoKey equalTo:self.photo];
		[queryForDislike whereKey:kSMTActivityFromUserKey equalTo:[PFUser currentUser]];

		PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
		[likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error)
			{
				self.activities = [objects mutableCopy];
				if ([self.activities count] == 0)
				{
					self.isLikedByCurrentUser = NO;
					self.isDislikedByCurrentUser = NO;
				}
				else
				{
					PFObject *activity = self.activities[0];

					if ([activity[kSMTActivityTypeKey] isEqualToString:kSMTActivityTypeLikeKey])
					{
						self.isLikedByCurrentUser = YES;
						self.isDislikedByCurrentUser = NO;
					}
					else if ([activity[kSMTActivityTypeKey] isEqualToString:kSMTActivityTypeDislikeKey])
					{
						self.isLikedByCurrentUser = NO;
						self.isDislikedByCurrentUser = YES;
					}
					else
					{
						// Some other type of activity [currently unused]
					}
				}

				// TODO: refactor this to only enable the button if the current like/dislike is NO respectively
				self.likeButton.enabled = YES;
				self.dislikeButton.enabled = YES;
				self.infoButton.enabled = YES;
			}
		}];
	}
}

-(void)updateView
{
	self.firstNameLabel.text = self.photo[kSMTPhotoUserKey][kSMTUserProfileKey][kSMTUserProfileFirstNameKey];
	self.ageLabel.text = [NSString stringWithFormat:@"%@",self.photo[kSMTPhotoUserKey][kSMTUserProfileKey][kSMTUserProfileAgeKey]];
	self.tagLineLabel.text = self.photo[kSMTPhotoUserKey][kSMTUserTagLineKey];
}

-(void)setupNextPhoto
{
	if (self.currentPhotoIndex + 1 <  self.photos.count)
	{
		self.currentPhotoIndex++;
		[self queryForCurrentPhotoIndex];
		[self updateView];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users" message:@"No more users to view. Check back later for more." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
}

-(void)saveLikeStatus:(BOOL)isLiked
{
	NSString *activityType;

	if (isLiked)
	{
		activityType = kSMTActivityTypeLikeKey;
	}
	else
	{
		activityType = kSMTActivityTypeDislikeKey;
	}

	PFObject *likeActivity = [PFObject objectWithClassName:kSMTActivityClassKey];
	[likeActivity setObject:activityType forKey:kSMTActivityTypeKey];
	[likeActivity setObject:[PFUser currentUser] forKey:kSMTActivityFromUserKey];
	[likeActivity setObject:[self.photo objectForKey:kSMTPhotoUserKey] forKey:kSMTActivityToUserKey];
	[likeActivity setObject:self.photo forKey:kSMTActivityPhotoKey];

	[likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		self.isLikedByCurrentUser = isLiked;
		self.isDislikedByCurrentUser = !isLiked;
		[self.activities addObject:likeActivity];
		[self checkForPhotoUserLikes];
		[self setupNextPhoto];
	}];
}

-(void)checkLikeStatus:(BOOL)isLiked
{
	BOOL isSameStatus;
	BOOL isOtherStatus;

	if (isLiked)
	{
		isSameStatus = self.isLikedByCurrentUser;
		isOtherStatus = self.isDislikedByCurrentUser;
	}
	else
	{
		isSameStatus = self.isDislikedByCurrentUser;
		isOtherStatus = self.isLikedByCurrentUser;
	}

	if (isSameStatus)
	{
		[self setupNextPhoto];
		return;
	}
	else if (isOtherStatus)
	{
		for (PFObject *activity in self.activities)
		{
			[activity deleteInBackground];
		}
		[self.activities removeLastObject];
		[self saveLikeStatus:isLiked];
	}
	else
	{
		[self saveLikeStatus:isLiked];
	}
}

-(void)checkForPhotoUserLikes
{
	PFQuery *query = [PFQuery queryWithClassName:kSMTActivityClassKey];
	[query whereKey:kSMTActivityFromUserKey equalTo:self.photo[kSMTPhotoUserKey]];
	[query whereKey:kSMTActivityToUserKey equalTo:[PFUser currentUser]];
	[query whereKey:kSMTActivityTypeKey equalTo:kSMTActivityTypeLikeKey];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error && [objects count] > 0)
		{
			// Create chatroom
			[self createChatroom];
		}
	}];
}

-(void)createChatroom
{
	PFQuery *queryForChatroom = [PFQuery queryWithClassName:@"ChatRoom"];
	[queryForChatroom whereKey:@"user1" equalTo:[PFUser currentUser]];
	[queryForChatroom whereKey:@"user2" equalTo:self.photo[kSMTPhotoUserKey]];

	PFQuery *queryForChatroomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
	[queryForChatroomInverse whereKey:@"user1" equalTo:self.photo[kSMTPhotoUserKey]];
	[queryForChatroomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];

	PFQuery *allChatroomQuery = [PFQuery orQueryWithSubqueries:@[queryForChatroom,queryForChatroomInverse]];
	[allChatroomQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		// If there aren't any chatrooms yet, create a new room
		if ([objects count] == 0)
		{
			PFObject *chatroom = [PFObject objectWithClassName:@"ChatRoom"];
			[chatroom setObject:[PFUser currentUser] forKey:@"user1"];
			[chatroom setObject:self.photo[kSMTPhotoUserKey] forKey:@"user2"];

			[chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				[self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
			}];
		}
		else
		{

		}
	}];

}

#pragma mark - <MatchViewControllerDelegate>

-(void)presentMatchesViewController
{
	[self dismissViewControllerAnimated:NO completion:^{
		[self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
	}];
}

@end
