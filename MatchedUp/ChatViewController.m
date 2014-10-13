//
//  ChatViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/12/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "ChatViewController.h"
#import "Constants.h"
#import <PFFile.h>

@interface ChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSTimer *chatsTimer;
@property (strong, nonatomic) NSMutableArray *chats;

@property (nonatomic) BOOL initialLoadComplete;

@end

@implementation ChatViewController 

-(NSMutableArray *)chats
{
	if (!_chats)
	{
		_chats = [[NSMutableArray alloc] init];
	}

	return _chats;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.delegate = self;
	self.dataSource = self;

	[[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
	self.messageInputView.textView.placeHolder = @"Enter new message";
	[self setBackgroundColor:[UIColor whiteColor]];
	self.currentUser = [PFUser currentUser];
	PFUser *chatroomUser1 = self.chatroom[@"user1"];
	if ([chatroomUser1.objectId isEqual:self.currentUser.objectId])
	{
		self.withUser = self.chatroom[@"user2"];
	}
	else
	{
		self.withUser = self.chatroom[@"user1"];
	}
	self.title = self.withUser[kSMTUserProfileKey][kSMTUserProfileFirstNameKey];
	self.initialLoadComplete = NO;

	[self checkForNewChats];
	self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
	[self.chatsTimer invalidate];
	self.chatsTimer = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.chats count];
}

#pragma mark - Messages view delegate - REQUIRED

-(void)didSendText:(NSString *)text
{
	if (text.length != 0)
	{
		PFObject *chat = [PFObject objectWithClassName:@"Chat"];
		[chat setObject:self.chatroom forKey:@"chatroom"];
		[chat setObject:self.currentUser forKey:@"fromUser"];
		[chat setObject:self.withUser forKey:@"toUser"];
		[chat setObject:text forKey:@"text"];
		[chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (!error)
			{
				[self.chats addObject:chat];
//				[JSMessageSoundEffect playMessageSentSound];
				[self.tableView reloadData];
				[self finishSend];
				[self scrollToBottomAnimated:YES];
			}
		}];
	}
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PFObject *chat = self.chats[indexPath.row];
	PFUser *chatroomUser1 = chat[@"fromUser"];
	if ([chatroomUser1.objectId isEqual:self.currentUser.objectId])
	{
		return JSBubbleMessageTypeOutgoing;
	}
	else
	{
		return JSBubbleMessageTypeIncoming;
	}
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
	PFObject *chat = self.chats[indexPath.row];
	PFUser *chatroomUser1 = chat[@"fromUser"];
	if ([chatroomUser1.objectId isEqual:self.currentUser.objectId])
	{
		return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
	}
	else
	{
		return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
	}
}

-(JSMessagesViewTimestampPolicy)timestampPolicy
{
	return JSMessagesViewTimestampPolicyAll;
}

-(JSMessagesViewAvatarPolicy)avatarPolicy
{
	return JSMessagesViewAvatarPolicyNone;
}

-(JSMessagesViewSubtitlePolicy)subtitlePolicy
{
	return JSMessagesViewSubtitlePolicyNone;
}

-(JSMessageInputViewStyle)inputViewStyle
{
	return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View delegate - OPTIONAL

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if ([cell messageType] == JSBubbleMessageTypeOutgoing)
	{
		cell.bubbleView.textView.textColor = [UIColor whiteColor];
	}
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
	return YES;
}

#pragma mark - Messages View Datasource - REQUIRED

-(NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PFObject *chat = self.chats[indexPath.row];
	NSString *message = chat[@"text"];

	return message;
}

-(NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark - Helper Methods

-(void)checkForNewChats
{
	int oldChatCount = [self.chats count];
	PFQuery *queryForChats = [PFQuery queryWithClassName:@"Chat"];
	[queryForChats whereKey:@"chatroom" equalTo:self.chatroom];
	[queryForChats orderByAscending:@"createdAt"];
	[queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			if (!self.initialLoadComplete || oldChatCount != [objects count])
			{
				self.chats = [objects mutableCopy];
				[self.tableView reloadData];

				// We don't want to play the "received" sound the first time the chat loads
				if (self.initialLoadComplete)
				{
//					[JSMessageSoundEffect playMessageReceivedSound];
				}

				self.initialLoadComplete = YES;
				[self scrollToBottomAnimated:YES];
			}
		}
	}];
}

@end
