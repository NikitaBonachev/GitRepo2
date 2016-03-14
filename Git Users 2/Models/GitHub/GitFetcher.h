//
//  GitFetcher.h
//  Git users
//
//  Created by Bonachev Nikita on 03.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class RepositoriesStore;

@interface GitFetcher : NSObject

- (void)getUsersFromNumber:(NSInteger)lastUserNumber;
- (void)getUserRepositories:(NSURL *)repositoriesURL forRepositoriesStore:(RepositoriesStore *)repositoriesStore;
- (void)searchUser:(NSString *)searchText;
+ (BOOL)checkConnection;

@end
