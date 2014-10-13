//
//  TestUser.m
//  MatchedUp
//
//  Created by Scott Brady on 10/11/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "TestUser.h"
#import "Constants.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <PFFile.h>

@implementation TestUser

+(void)saveTestUserToParse
{
	PFUser *newUser = [PFUser user];
	newUser.username = @"user1";
	newUser.password = @"password1";

	[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (!error)
		{
			NSDictionary *profile = @{kSMTUserProfileAgeKey: @28, kSMTUserProfileBirthdayKey: @"11/22/1985", kSMTUserProfileFirstNameKey: @"Jake", kSMTUserProfileGenderKey: @"male", kSMTUserProfileLocationKey: @"Los Angeles, CA", kSMTUserProfileNameKey: @"Jake Gyllenhaal"};
			[newUser setObject:profile forKey:kSMTUserProfileKey];
			[newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (succeeded)
				{
					UIImage *profileImage = [UIImage imageNamed:@"jakeGyllenhaal.jpeg"];
					NSData *imageData = UIImageJPEGRepresentation(profileImage, 0.8);
					PFFile *photoFile = [PFFile fileWithData:imageData];
					[photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
						if (succeeded)
						{
							PFObject *photo = [PFObject objectWithClassName:kSMTPhotoClassKey];
							[photo setObject:newUser forKey:kSMTPhotoUserKey];
							[photo setObject:photoFile forKey:kSMTPhotoPictureKey];
							[photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
								NSLog(@"Test user photo saved successfully.");
							}];
						}
						else
						{
							NSLog(@"Error saving new user's photo: %@",error);
						}
					}];
				}
				else
				{
					NSLog(@"Error saving new user: %@",error);
				}
			}];
		}
		else
		{
			// TODO: handle error
			NSLog(@"Error signing up new user: %@",error);
		}
	}];
}

@end
