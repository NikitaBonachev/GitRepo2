//
//  Repositories.h
//  Git Users 2
//
//  Created by Bonachev Nikita on 06.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepositoriesStore : NSObject

@property (nonatomic, readonly) NSArray *repositories;

- (instancetype)initStoreForUserID:(NSInteger)uID repositoryURL:(NSURL *)repositoriesURL;
- (void)addRepositoriesFromArray:(NSArray *)newRepositories;

@end
