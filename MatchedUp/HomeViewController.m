//
//  HomeViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/9/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import <FacebookSDK/FacebookSDK.h>
#import <PFQuery.h>
#import <PFFile.h>


@interface HomeViewController ()

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

	// We don't want users to be able to push the buttons before the pictures download
	self.likeButton.enabled = NO;
	self.dislikeButton.enabled = NO;
	self.infoButton.enabled = NO;

	self.currentPhotoIndex = 0;

	// Query to get the other users
	PFQuery *query = [PFQuery queryWithClassName:kSMTPhotoClassKey];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender
{

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
		[self setupNextPhoto];
	}];
}

/* TODO: remove
-(void)saveLike
{
	PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
	[likeActivity setObject:@"like" forKey:@"type"];
	[likeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
	[likeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
	[likeActivity setObject:self.photo forKey:@"photo"];

	[likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		self.isLikedByCurrentUser = YES;
		self.isDislikedByCurrentUser = NO;
		[self.activities addObject:likeActivity];
		[self setupNextPhoto];
	}];
}

-(void)saveDislike
{
	PFObject *dislikeActivity = [PFObject objectWithClassName:@"Activity"];
	[dislikeActivity setObject:@"dislike" forKey:@"type"];
	[dislikeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
	[dislikeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
	[dislikeActivity setObject:self.photo forKey:@"photo"];

	[dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		self.isLikedByCurrentUser = NO;
		self.isDislikedByCurrentUser = YES;
		[self.activities addObject:dislikeActivity];
		[self setupNextPhoto];
	}];
}
*/

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

/* TODO: remove
-(void)checkLike
{
	if (self.isLikedByCurrentUser)
	{
		[self setupNextPhoto];
		return;
	}
	else if (self.isDislikedByCurrentUser)
	{
		for (PFObject *activity in self.activities)
		{
			[activity deleteInBackground];
		}
		[self.activities removeLastObject];
		[self saveLikeStatus:YES];
	}
	else
	{
		[self saveLikeStatus:YES];
	}
}

-(void)checkDislike
{
	if (self.isDislikedByCurrentUser)
	{
		[self setupNextPhoto];
		return;
	}
	else if (self.isLikedByCurrentUser)
	{
		for (PFObject *activity in self.activities)
		{
			[activity deleteInBackground];
		}
		[self.activities removeLastObject];
		[self saveLikeStatus:NO];
	}
	else
	{
		[self saveLikeStatus:NO];
	}
}
*/

@end
