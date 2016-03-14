//
//  Repositories.m
//  Git Users 2
//
//  Created by Bonachev Nikita on 06.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "RepositoriesStore.h"
#import "FMDB.h"
#import "Repository.h"
#import "GitFetcher.h"

@interface RepositoriesStore()
@property (nonatomic, strong) NSMutableArray *privateRepositories;
@property (nonatomic, strong) NSURL *repositoriesURL;
@property (nonatomic) NSInteger userID;
@end

@implementation RepositoriesStore

- (instancetype)initStoreForUserID:(NSInteger)uID repositoryURL:(NSURL *)repositoriesURL {
	self = [super init];
	if (self) {
		self.repositoriesURL = repositoriesURL;
		self.userID = uID;
		self.privateRepositories = [[NSMutableArray alloc] init];
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
			[self.privateRepositories addObjectsFromArray:[FMDB loadRepositoriesForUserID:uID repositoriesURL:repositoriesURL]];
			if ([self.privateRepositories count] == 0) {
				GitFetcher *gitFetcher = [[GitFetcher alloc] init];
				[gitFetcher getUserRepositories:repositoriesURL forRepositoriesStore:self];
			} else {
				dispatch_async(dispatch_get_main_queue(), ^(void){
						[[NSNotificationCenter defaultCenter] postNotificationName:@"RepositoriesDataChanged" object:self];
				});
			}
		});
	}
	return self;
}

- (void)addRepositoriesFromArray:(NSArray *)newRepositories
{
	[self.privateRepositories addObjectsFromArray:newRepositories];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RepositoriesDataChanged" object:self];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
		[FMDB addRepositoriesFromArray:newRepositories];
	});
}

- (NSArray *)repositories
{
	return self.privateRepositories;
}

@end
