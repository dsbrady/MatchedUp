//
//  Constants.m
//  MatchedUp
//
//  Created by Scott Brady on 10/7/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#pragma mark - User Class

NSString *const kSMTUserTagLineKey						= @"tagLine";

NSString *const kSMTUserProfileKey						= @"profile";
NSString *const kSMTUserProfileNameKey					= @"name";
NSString *const kSMTUserProfileFirstNameKey				= @"firstName";
NSString *const kSMTUserProfileLocationKey				= @"location";
NSString *const kSMTUserProfileGenderKey				= @"gender";
NSString *const kSMTUserProfileBirthdayKey				= @"birthday";
NSString *const kSMTUserProfileInterestedInKey			= @"interestedIn";
NSString *const kSMTUserProfilePictureURLKey			= @"pictureURL";
NSString *const kSMTUserProfileRelationshipStatusKey	= @"relationshipStatus";
NSString *const kSMTUserProfileAgeKey 					= @"age";

#pragma mark - Photo Class
NSString *const kSMTPhotoClassKey						= @"Photo";
NSString *const kSMTPhotoUserKey						= @"user";
NSString *const kSMTPhotoPictureKey						= @"image";

#pragma mark - Activity Class
NSString *const kSMTActivityClassKey					= @"Activity";
NSString *const kSMTActivityTypeKey						= @"type";
NSString *const kSMTActivityFromUserKey					= @"fromUser";
NSString *const kSMTActivityToUserKey					= @"toUser";
NSString *const kSMTActivityPhotoKey					= @"photo";
NSString *const kSMTActivityTypeLikeKey					= @"like";
NSString *const kSMTActivityTypeDislikeKey				= @"dislike";

#pragma mark - Settings
NSString *const kSMTMenEnabledKey						= @"men";
NSString *const kSMTWomenEnabledKey						= @"women";
NSString *const kSMTSinglesEnabledKey					= @"single";
NSString *const kSMTAgeMaxKey							= @"ageMax";

@end
