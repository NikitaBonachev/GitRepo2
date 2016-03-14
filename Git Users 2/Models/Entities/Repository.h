//
//  Repository.h
//  Git users
//
//  Created by Bonachev Nikita on 04.03.16.
//  Copyright © 2016 Bonachev Nikita. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Repository : NSObject

@property (strong, nonatomic, readonly) NSString *repositoryName;
@property (strong, nonatomic, readonly) NSString *repositoryDescription;
@property (strong, nonatomic, readonly) NSURL *repositoryURL;
@property (strong, nonatomic, readonly) NSURL *ownerURL;
@property (nonatomic, readonly) BOOL fork;
@property (nonatomic, readonly) NSInteger ownerID;
@property (nonatomic, readonly) NSInteger repositoryID;

- (instancetype)initWithRepositoryName:(NSString *)name repositoryID:(NSInteger)repoID repositoryDescription:(NSString *)desc repositoryURL:(NSURL*)repoURL ownerID:(NSInteger)ownID ownerURL:(NSURL *)ownerURL fork:(BOOL)f;

@end
