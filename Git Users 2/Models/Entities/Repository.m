//
//  Repository.m
//  Git users
//
//  Created by Bonachev Nikita on 04.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "Repository.h"

@interface Repository()
@property (strong, nonatomic) NSString *repositoryName;
@property (strong, nonatomic) NSString *repositoryDescription;
@property (strong, nonatomic) NSURL *repositoryURL;
@property (strong, nonatomic) NSURL *ownerURL;
@property (nonatomic) BOOL fork;
@property (nonatomic) NSInteger ownerID;
@property (nonatomic) NSInteger repositoryID;
@end

@implementation Repository

- (instancetype)initWithRepositoryName:(NSString *)name repositoryID:(NSInteger)repoID repositoryDescription:(NSString *)desc repositoryURL:(NSURL*)repoURL ownerID:(NSInteger)ownID ownerURL:(NSURL *)ownerURL fork:(BOOL)f {
	self = [super init];
	if (self) {
		self.repositoryID = repoID;
		self.ownerID = ownID;
		self.repositoryName = name;
		self.repositoryDescription = desc;
		self.repositoryURL = repoURL;
		self.ownerURL = ownerURL;
		self.fork = f;
	}
	return self;
}

@end
