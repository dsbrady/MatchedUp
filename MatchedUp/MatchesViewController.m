//
//  MatchesViewController.m
//  MatchedUp
//
//  Created by Scott Brady on 10/12/14.
//  Copyright (c) 2014 Spider Monkey Tech. All rights reserved.
//

#import "MatchesViewController.h"
#import "ChatViewController.h"
#import "Constants.h"
#import <PFQuery.h>
#import <PFFile.h>

@interface MatchesViewController () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableChatrooms;

@end

@implementation MatchesViewController

#pragma mark - Lazy instantiation

-(NSMutableArray *)availableChatrooms
{
	if (!_availableChatrooms)
	{
		_availableChatrooms = [[NSMutableArray alloc] init];
	}

	return _availableChatrooms;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	self.tableView.delegate = self;
	self.tableView.dataSource = self;

	[self updateAvailableChatrooms];
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

	ChatViewController *chatVC = segue.destinationViewController;
	NSIndexPath *indexPath = sender;
	chatVC.chatroom = self.availableChatrooms[indexPath.row];
}

#pragma mark - Helper methods

-(void)updateAvailableChatrooms
{
	PFQuery *user1Query = [PFQuery queryWithClassName:@"ChatRoom"];
	[user1Query whereKey:@"user1" equalTo:[PFUser currentUser]];

	PFQuery *user2Query = [PFQuery queryWithClassName:@"ChatRoom"];
	[user1Query whereKey:@"user2" equalTo:[PFUser currentUser]];

	PFQuery *chatroomsQuery = [PFQuery orQueryWithSubqueries:@[user1Query,user2Query]];
	[chatroomsQuery includeKey:@"chat"];
	[chatroomsQuery includeKey:@"user1"];
	[chatroomsQuery includeKey:@"user2"];
	[chatroomsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error)
		{
			[self.availableChatrooms removeAllObjects];
			self.availableChatrooms = [objects mutableCopy];
			[self.tableView reloadData];
		}
	}];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.availableChatrooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

	PFObject *chatRoom = [self.availableChatrooms objectAtIndex:indexPath.row];

	PFUser *likedUser;
	PFUser *currentUser = [PFUser currentUser];
	PFUser *chatroomUser1 = chatRoom[@"user1"];

	if ([chatroomUser1.objectId isEqual:currentUser.objectId])
	{
		likedUser = [chatRoom objectForKey:@"user2"];
	}
	else
	{
		likedUser = [chatRoom objectForKey:@"user1"];
	}

	cell.textLabel.text = likedUser[kSMTUserProfileKey][kSMTUserProfileFirstNameKey];

	// Cell.imageView.image = place holder image
	cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

	PFQuery *photoQuery = [[PFQuery alloc] initWithClassName:@"Photo"];
	[photoQuery whereKey:@"user" equalTo:likedUser];
	[photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error && [objects count] > 0)
		{
			PFObject *photo = objects[0];
			PFFile *pictureFile = photo[kSMTPhotoPictureKey];
			[pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
				if (!error)
				{
					cell.imageView.image = [UIImage imageWithData:data];
					cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
				}
			}];
		}
	}];

	return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"matchesToChatSegue" sender:indexPath];
}

@end
