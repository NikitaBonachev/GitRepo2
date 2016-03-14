//
//  FMDB.h
//  Git Users 2
//
//  Created by Bonachev Nikita on 12.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface FMDB : NSObject

+ (NSMutableArray *)loadRepositoriesForUserID:(NSInteger)userID repositoriesURL:(NSURL *)repositoriesURL;
+ (NSMutableArray *)loadUsers;

+ (void)addRepositoriesFromArray:(NSArray *)newRepositories;
+ (void)addUsersFromArray:(NSArray *)newUsers;
+ (void)removeAllUsers;

@end
