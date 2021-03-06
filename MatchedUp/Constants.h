//
//  Constants.h
//  MatchedUp
//
//  Created by Scott Brady on 10/7/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#pragma mark - User Class

extern NSString *const kSMTUserTagLineKey;

extern NSString *const kSMTUserProfileKey;
extern NSString *const kSMTUserProfileNameKey;
extern NSString *const kSMTUserProfileFirstNameKey;
extern NSString *const kSMTUserProfileLocationKey;
extern NSString *const kSMTUserProfileGenderKey;
extern NSString *const kSMTUserProfileBirthdayKey;
extern NSString *const kSMTUserProfileInterestedInKey;
extern NSString *const kSMTUserProfilePictureURLKey;
extern NSString *const kSMTUserProfileRelationshipStatusKey;
extern NSString *const kSMTUserProfileAgeKey;

#pragma mark - Photo Class
extern NSString *const kSMTPhotoClassKey;
extern NSString *const kSMTPhotoUserKey;
extern NSString *const kSMTPhotoPictureKey;

#pragma mark - Activity Class
extern NSString *const kSMTActivityClassKey;
extern NSString *const kSMTActivityTypeKey;
extern NSString *const kSMTActivityFromUserKey;
extern NSString *const kSMTActivityToUserKey;
extern NSString *const kSMTActivityPhotoKey;
extern NSString *const kSMTActivityTypeLikeKey;
extern NSString *const kSMTActivityTypeDislikeKey;

#pragma mark - Settings
extern NSString *const kSMTMenEnabledKey;
extern NSString *const kSMTWomenEnabledKey;
extern NSString *const kSMTSinglesEnabledKey;
extern NSString *const kSMTAgeMaxKey;

#pragma mark - ChatRoom
extern NSString *const kSMTChatRoomClassKey;
extern NSString *const kSMTChatRoomUser1Key;
extern NSString *const kSMTChatRoomUser2Key;

#pragma mark - Chat
extern NSString *const kSMTChatClassKey;
extern NSString *const kSMTChatChatRoomKey;
extern NSString *const kSMTChatFromUserKey;
extern NSString *const kSMTChatToUserKey;
extern NSString *const kSMTChatTextKey;

#pragma mark - Mixpanel
extern NSString *const kSMTMixpanelToken;


@end
