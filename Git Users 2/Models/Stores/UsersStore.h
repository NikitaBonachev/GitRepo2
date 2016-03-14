//
//  UsersStore.h
//  Git users
//
//  Created by Bonachev Nikita on 05.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UsersStore : NSObject

@property (nonatomic, readonly) NSArray *users;
@property (nonatomic, readonly) NSArray *usersSearchResult;

+ (instancetype)sharedStore;
+ (void)addUsersFromArray:(NSArray *)newUsers;
+ (void)removeAllUsers;
+ (void)reloadStore;
+ (void)setSearchPredicate:(NSString *)searchText;
+ (void)addSearchResultFromArray:(NSArray *)array;
+ (void)removeAllSearchResult;

@end
