//
//  FMDB.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 12.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "FMDB.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "AppDelegate.h"
#import "Repository.h"
#import "RepositoriesStore.h"
#import "User.h"
#import "UsersStore.h"

@implementation FMDB

+ (FMDatabaseQueue *)queue {
	static FMDatabaseQueue *queue = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; // Получаем AppDelegate
		queue = [FMDatabaseQueue databaseQueueWithPath:[appDelegate databasePath]];
	});
	return queue;
}


#pragma mark - Repositories

+ (NSMutableArray *)loadRepositoriesForUserID:(NSInteger)userID repositoriesURL:(NSURL *)repositoriesURL {
	NSString *userIDString = [NSString stringWithFormat:@"%ld", (long)userID];
	NSMutableArray *loadedRepositories = [[NSMutableArray alloc] init];
	
	NSString *stringQuery = [NSString stringWithFormat:@"SELECT * FROM repositories WHERE ownerID = %@", userIDString];
	
	[[FMDB queue] inDatabase:^(FMDatabase *db) {
		FMResultSet *results = [db executeQuery:stringQuery];
		
		while ([results next]) {
				Repository *repository = [[Repository alloc] initWithRepositoryName:[results stringForColumn:@"repositoryName"]
																	   repositoryID:[results intForColumn:@"repositoryID"]
															  repositoryDescription:[results stringForColumn:@"repositoryDescription"]
																	  repositoryURL:[NSURL URLWithString:[results stringForColumn:@"repositoryURL"]]
																			ownerID:[results intForColumn:@"ownerID"]
																		   ownerURL:[NSURL URLWithString:[results stringForColumn:@"ownerUrl"]]
																			   fork:[results boolForColumn:@"fork"]];
				[loadedRepositories addObject:repository];
		}
	}];
	
	return loadedRepositories;
}

+ (void)addRepositoriesFromArray:(NSArray *)newRepositories {
	for (Repository *newRepo in newRepositories) {
		NSString *idRepoString = [NSString stringWithFormat:@"%ld", (long)[newRepo repositoryID]];
		NSString *idOwnerString = [NSString stringWithFormat:@"%ld", (long)[newRepo ownerID]];
		NSString *fork = [newRepo fork] ? @"1" : @"0";
		
		[[FMDB queue] inDatabase:^(FMDatabase *db) {
			[db  executeUpdate:@"INSERT INTO repositories (repositoryName, repositoryID, repositoryDescription, repositoryURL, ownerURL, ownerID, fork) VALUES (?, ?, ?, ?, ?, ?, ?)",
			 [newRepo repositoryName], idRepoString, [newRepo repositoryDescription], [newRepo.repositoryURL absoluteString], [newRepo.ownerURL absoluteString], idOwnerString, fork ?: [NSNull null]];
		}];
	}
}

#pragma mark - Users

+ (NSMutableArray *)loadUsers {
	NSMutableArray *users = [[NSMutableArray alloc] init];
	
	[[FMDB queue] inDatabase:^(FMDatabase *db) {
		FMResultSet *results = [db executeQuery:@"SELECT * FROM users"];
		while ([results next])
		{
			User *user = [[User alloc] initWithUserName:[results stringForColumn:@"userName"]
											   photoURL:[NSURL URLWithString:[results stringForColumn:@"photoURL"]]
										repositoriesURL:[NSURL URLWithString:[results stringForColumn:@"repositoriesURL"]]
												 userID:[results intForColumn:@"userID"]];
			[users addObject:user];
		}
	}];

	return users;
}

+ (void)addUsersFromArray:(NSArray *)newUsers {
	for (User *newUser in newUsers) {
		NSString *IDString = [NSString stringWithFormat:@"%ld", (long)newUser.userID];
		NSString *query =  [NSString stringWithFormat:@"SELECT userID FROM users WHERE userID = %@", IDString];
		
		[[self queue] inDatabase:^(FMDatabase *db) {
			FMResultSet *results = [db executeQuery:query];
			if (![results next]) {
				[db executeUpdate:@"INSERT INTO users (userID, userName, repositoriesURL, photoURL) VALUES (?, ?, ?, ?)",
				 IDString, newUser.userName, [newUser.repositoriesURL absoluteString], [newUser.photoURL absoluteString] ?: [NSNull null]];
			}
		}];
	}
}

+ (void)removeAllUsers {
	[[FMDB queue] inDatabase:^(FMDatabase *db) {
		[db executeUpdate:@"DELETE FROM users"];
		[db executeUpdate:@"DELETE FROM repositories"];
	}];
}

@end
