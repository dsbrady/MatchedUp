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

#pragma mark - ChatRoom
NSString *const kSMTChatRoomClassKey					= @"ChatRoom";
NSString *const kSMTChatRoomUser1Key					= @"user1";
NSString *const kSMTChatRoomUser2Key					= @"user2";

#pragma mark - Chat
NSString *const kSMTChatClassKey						= @"Chat";
NSString *const kSMTChatChatRoomKey						= @"chatroom";
NSString *const kSMTChatFromUserKey						= @"fromUser";
NSString *const kSMTChatToUserKey						= @"toUser";
NSString *const kSMTChatTextKey							= @"text";

#pragma mark - Mixpanel
NSString *const kSMTMixpanelToken						= @"e53239a2fe114386a58faccc1b63330c";

@end
