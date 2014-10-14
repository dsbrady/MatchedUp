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
#import "MatchTransitionAnimator.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Mixpanel.h>
#import <PFQuery.h>
#import <PFFile.h>

@interface HomeViewController () <MatchViewControllerDelegate, ProfileViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;

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
	[self setupViews];
}

-(void)viewDidAppear:(BOOL)animated
{
	self.photoImageView.image = nil;
	self.firstNameLabel.text = nil;
	self.ageLabel.text = nil;

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
			if (![self allowPhoto])
			{
				[self setupNextPhoto];
			}
			else
			{
				[self queryForCurrentPhotoIndex];
				[self updateView];
			}
		}
		else
		{
			NSLog(@"Error getting users: %@",error);
		}
	}];

}

-(void)setupViews
{
	self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];

	[self addShadowForView:self.buttonContainerView];
	[self addShadowForView:self.labelContainerView];
	self.photoImageView.layer.masksToBounds = YES;
}

-(void)addShadowForView:(UIView *)view
{
	view.layer.masksToBounds = NO;
	view.layer.cornerRadius = 4;
	view.layer.shadowRadius = 1;
	view.layer.shadowOffset = CGSizeMake(0, 1);
	view.layer.shadowOpacity = 0.25;
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
		profileVC.delegate = self;
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
	Mixpanel *mixpanel = [Mixpanel sharedInstance];

	[mixpanel track:@"Like"];
	[mixpanel flush];

	[self checkLikeStatus:YES];
}

- (IBAction)dislikebuttonPressed:(UIButton *)sender
{
	Mixpanel *mixpanel = [Mixpanel sharedInstance];

	[mixpanel track:@"Dislike"];
	[mixpanel flush];
	
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
}

-(void)setupNextPhoto
{
	if (self.currentPhotoIndex + 1 <  self.photos.count)
	{
		self.currentPhotoIndex++;
		if (![self allowPhoto])
		{
			[self setupNextPhoto];
		}
		else
		{
			[self queryForCurrentPhotoIndex];
			[self updateView];
		}
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
	PFQuery *queryForChatroom = [PFQuery queryWithClassName:kSMTChatRoomClassKey];
	[queryForChatroom whereKey:kSMTChatRoomUser1Key equalTo:[PFUser currentUser]];
	[queryForChatroom whereKey:kSMTChatRoomUser2Key equalTo:self.photo[kSMTPhotoUserKey]];

	PFQuery *queryForChatroomInverse = [PFQuery queryWithClassName:kSMTChatRoomClassKey];
	[queryForChatroomInverse whereKey:kSMTChatRoomUser1Key equalTo:self.photo[kSMTPhotoUserKey]];
	[queryForChatroomInverse whereKey:kSMTChatRoomUser2Key equalTo:[PFUser currentUser]];

	PFQuery *allChatroomQuery = [PFQuery orQueryWithSubqueries:@[queryForChatroom,queryForChatroomInverse]];
	[allChatroomQuery findObjectsInBackgroundWithBlock:^(NSArray *chatrooms, NSError *error) {
		// If there aren't any chatrooms yet, create a new room
		if ([chatrooms count] == 0)
		{
			PFObject *chatroom = [PFObject objectWithClassName:kSMTChatRoomClassKey];
			[chatroom setObject:[PFUser currentUser] forKey:kSMTChatRoomUser1Key];
			[chatroom setObject:self.photo[kSMTPhotoUserKey] forKey:kSMTChatRoomUser2Key];

			[chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				UIStoryboard *myStoryboard = self.storyboard;
				MatchViewController *matchViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"matchVC"];
				matchViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.75];
				matchViewController.transitioningDelegate = self;
				matchViewController.matchedUserImage = self.photoImageView.image;
				matchViewController.delegate = self;
				matchViewController.modalPresentationStyle = UIModalPresentationCustom;
				[self presentViewController:matchViewController animated:YES completion:nil];
			}];
		}
		else
		{

		}
	}];
}

-(BOOL)allowPhoto
{
	int maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kSMTAgeMaxKey];
	BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kSMTMenEnabledKey];
	BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kSMTWomenEnabledKey];
	BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kSMTSinglesEnabledKey];

	PFObject *photo = self.photos[self.currentPhotoIndex];
	PFUser *user = photo[kSMTPhotoUserKey];

	int userAge = [user[kSMTUserProfileKey][kSMTUserProfileAgeKey] intValue];
	NSString *gender = user[kSMTUserProfileKey][kSMTUserProfileGenderKey];
	NSString *relationshipStatus = user[kSMTUserProfileKey][kSMTUserProfileRelationshipStatusKey];

	if (userAge > maxAge)
	{
		return NO;
	}
	else if (men == NO && [gender isEqualToString:@"male"])
	{
		return NO;
	}
	else if (women == NO && [gender isEqualToString:@"female"])
	{
		return NO;
	}
	else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil))
	{
		return NO;
	}

	return YES;
}

#pragma mark - <MatchViewControllerDelegate>

-(void)presentMatchesViewController
{
	[self dismissViewControllerAnimated:NO completion:^{
		[self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
	}];
}

#pragma mark - <ProfileViewControllerDelegate>

-(void)didPressLike
{
	[self.navigationController popViewControllerAnimated:NO];
	[self checkLikeStatus:YES];
}

-(void)didPressDislike
{
	[self.navigationController popViewControllerAnimated:NO];
	[self checkLikeStatus:NO];
}

#pragma mark - <UIViewControllerTransitioningDelegate>

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
	MatchTransitionAnimator *animator = [[MatchTransitionAnimator alloc] init];
	animator.presenting = YES;

	return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
	MatchTransitionAnimator *animator = [[MatchTransitionAnimator alloc] init];

	return animator;
}

@end
