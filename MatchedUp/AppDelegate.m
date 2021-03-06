//
//  AppDelegate.m
//  MatchedUp
//
//  Created by Scott Brady on 10/6/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Mixpanel.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

// TODO:  figure out why JSQ messages sounds don't play

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	[Parse setApplicationId:@"W6LXysVNwh78mqqSdMah4la72lgzODAB1ZAwguZt" clientKey:@"g8sb7BQL0GY8HFSfMoGHL7tLaRkpePBrAAPI8LPE"];

	// Register for Push Notitications, if running iOS 8
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
	{
		UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |UIUserNotificationTypeSound);
  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
																		   categories:nil];
		[application registerUserNotificationSettings:settings];
		[application registerForRemoteNotifications];
	}
	else
	{
		// Register for Push Notifications before iOS 8
		[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
	}

	[PFFacebookUtils initializeFacebook];

	[Mixpanel sharedInstanceWithToken:kSMTMixpanelToken];

	NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPreferences" ofType:@"plist"];
	NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];

	[[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:12/255.0 green:158/255.0 blue:255/255.0 alpha:1.0], NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]}];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Parse methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	// Store the deviceToken in the current installation and save it to Parse.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	[currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[PFPush handlePush:userInfo];
}

#pragma mark - Facebook methods

- (BOOL)application:(UIApplication *)application
			openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
		 annotation:(id)annotation {
	// attempt to extract a token from the url
	return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

@end
