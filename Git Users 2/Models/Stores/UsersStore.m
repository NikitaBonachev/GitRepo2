//
//  UsersStore.m
//  Git users
//
//  Created by Bonachev Nikita on 05.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "UsersStore.h"
#import "GitFetcher.h"
#import "User.h"
#import "FMDB.h"

@implementation UsersStore

+ (instancetype)sharedStore {
	static UsersStore *sharedStore = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedStore = [[self alloc] init];
	});
	return sharedStore;
}

static NSMutableArray *users = nil;
static NSMutableArray *usersSearchFromGit = nil;
static NSString *searchText = @"";

#pragma mark - Search text

+ (NSString *) searchText {
	return searchText;
}

+ (void) setSearchText:(NSString *)newSearchText {
	searchText = newSearchText;
}

#pragma mark - Get arrays

- (NSArray *)users {
	return [UsersStore privateUsers];
}

- (NSArray *)usersSearchResult {
	return [UsersStore privateUsersSearchResult];
}

#pragma mark - Add new

+ (void)addSearchResultFromArray:(NSArray *)array
{
	usersSearchFromGit = [[NSMutableArray alloc] init];
	// Проверка на уникальность результата
	for (User *newUser in array) {
		BOOL toAdd = true;
		for (User *user in [self privateUsersSearchResult]) {
			if ([newUser userID] == [user userID]) {
				toAdd = false;
				break;
			}
		}
		if (toAdd) {
			[usersSearchFromGit addObject:newUser];
		}
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NewSearchResult" object:self];
}

+ (void)addUsersFromArray:(NSArray *)newUsers {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		[FMDB addUsersFromArray:newUsers];
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[[UsersStore privateUsers] addObjectsFromArray:newUsers];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"UsersDataChanged" object:self];
		});
	});
}

+ (void)setSearchPredicate:(NSString *)searchText {
	[UsersStore setSearchText:searchText];
}

#pragma mark - Перезагрузка хранилища

+ (void)removeAllUsers {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		[FMDB removeAllUsers];
		[[UsersStore privateUsers] removeAllObjects];
		[self reloadStore];
	});
}

+ (void)reloadStore {
	usersSearchFromGit = [[NSMutableArray alloc] init];
	users = [[NSMutableArray alloc] init];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		users = [FMDB loadUsers];
		if ([users count] == 0) {
			GitFetcher *gitFetcher = [[GitFetcher alloc] init];
			[gitFetcher getUsersFromNumber:0];
		}
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SuccessReloadUserStore" object:self];
		});
	});
}

+ (void)removeAllSearchResult {
	usersSearchFromGit = [[NSMutableArray alloc] init];
	[[UsersStore privateUsersSearchResult] removeAllObjects];
}

#pragma mark - Private

+ (NSMutableArray *)privateUsers {
	if (users == nil) {
		users = [[NSMutableArray alloc] init];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
			users = [FMDB loadUsers];
			if ([users count] == 0) {
				GitFetcher *gitFetcher = [[GitFetcher alloc] init];
				[gitFetcher getUsersFromNumber:0];
			}
			dispatch_async(dispatch_get_main_queue(), ^(void){
				[[NSNotificationCenter defaultCenter] postNotificationName:@"UsersDataChanged" object:self];
			});
		});
	}
	return users;
}

+ (NSMutableArray *)privateUsersSearchResult {
	NSMutableArray *privateUsersSearchResult = [[NSMutableArray alloc] init];
	
	if ([searchText isEqualToString:@""]) {
		[privateUsersSearchResult addObjectsFromArray:[self privateUsers]];
	} else {
		NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"userName contains[c] %@", [UsersStore searchText]];
		[privateUsersSearchResult addObjectsFromArray:[[self privateUsers] filteredArrayUsingPredicate:resultPredicate]];
		
	}
	
	[privateUsersSearchResult addObjectsFromArray:usersSearchFromGit];
	
	return privateUsersSearchResult;
}

@end
