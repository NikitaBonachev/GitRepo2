//
//  User.m
//  Git users
//
//  Created by Bonachev Nikita on 03.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import "User.h"

@interface User ()
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic,) NSURL *photoURL;
@property (strong, nonatomic) NSURL *repositoriesURL;
@property (nonatomic) NSInteger userID;
@end

@implementation User

- (instancetype)initWithUserName:(NSString *)name photoURL:(NSURL *)phURL repositoriesURL:(NSURL *)reposURL userID:(NSInteger)uID {
	self = [super init];
	if (self) {
		self.userName = name;
		self.photoURL = phURL;
		self.repositoriesURL = reposURL;
		self.userID = uID;
	}
	return self;
}

@end
